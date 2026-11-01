# Modelo de tenant y aislamiento

Documento de referencia. Si vas a tocar persistencia, autenticación o
aislamiento de datos, leé esto primero. Si algo acá contradice al código,
**gana este documento** (y hay que corregir el código).

## TL;DR

- **Fase 1 es single-tenant con `tenant_id = "default"`.** Un docente, una
  sala activa, un quiz en curso.
- **El esquema SQLite incluye `tenant_id` desde el día uno**, aunque valga
  `"default"`. Es la inversión que hace que Fase 2 no sea una reescritura.
- **Hot path intacto:** el estado de sala vive en memoria (ADR-0004). SQLite
  se toca solo en bordes (cierre de sala, reportes).
- **Cero datos de alumnos persistidos.** Solo agregados por pregunta.
- **Aislamiento entre alumnos** se hace por asociación de conexión WebSocket
  a una sala, no por un campo que el cliente pueda cambiar.
- **Autenticación docente:** token estático en Fase 1, OAuth en Fase 2.
  La interfaz `Authenticator` es estable.
- **Aislamiento físico entre tenants en Fase 2:** un archivo SQLite por
  tenant. No row-level security emulada en aplicación.

## Qué es un tenant en aulaQuiz

Un **tenant** es una unidad de aislamiento lógico. Agrupa:

- Un conjunto de quizzes.
- Un conjunto de estadísticas de partidas.
- (En Fase 2) Un docente o un grupo de docentes (cohorte, cátedra, facultad).

En Fase 1 hay **un solo tenant**, con `id = "default"`. No hay concepto de
“elegir tenant” en la UI ni en la API.

En Fase 2, cada docente autenticado por OAuth pertenece a uno o más tenants.
El `tenant_id` se resuelve a partir de la identidad del docente y baja por
`context.Context` hasta el repositorio.

## Principio rector

> El `tenant_id` **nunca** viene del cliente. Siempre viene del contexto,
> inyectado por el middleware a partir de la sesión autenticada (o
> `"default"` en Fase 1).

Esto aplica a:
- Queries de lectura (reportes).
- Queries de escritura (cierre de sala).
- Apertura de conexiones SQLite (una por tenant en Fase 2).
- Carga de quizzes (un directorio por tenant en Fase 2).

Ningún mensaje WebSocket lleva `tenant_id`. Ninguna URL lo lleva como query
param. Si un día hace falta exponerlo en la API, se hace como path param
validado contra la sesión, nunca como algo que el cliente elige libremente.

## Modelos de despliegue

### Modelo A — Instancia por docente (auto-alojable puro)

- Cada docente corre su propio binario.
- Cada instancia tiene un solo tenant (`default`).
- Backup = `cp data/tenants/default.db backup/`.
- No hay OAuth: el docente es dueño de su instancia.

**Ventaja:** cero infraestructura compartida, cero obligaciones entre docentes.
**Desventaja:** si querés estadísticas agregadas entre docentes, no las tenés
(salvo que compartan archivos manualmente).

### Modelo B — Instancia compartida por facultad (multi-tenant)

- Un servidor, varios docentes autenticados por OAuth.
- Un archivo SQLite por tenant (`data/tenants/<tenant_id>.db`).
- Aislamiento por archivo: un docente no puede leer el `.db` de otro.
- Reportes filtrados por `tenant_id` del contexto.

**Ventaja:** estadísticas compartidas por tenant, gestión centralizada.
**Desventaja:** una instancia, un punto de fallo, necesidad de backups
coordinados.

### La decisión

- **Fase 1:** Modelo A en operación, con esquema preparado para Modelo B.
- **Fase 2:** Modelo B, activado por demanda. Si en 6 meses otros docentes
  se suman, se enciende OAuth y se crea un `.db` por docente. No se reescribe
  nada, se cambia el middleware de autenticación y la apertura de conexión.

El proyecto **no cierra** el modelo A: si alguien quiere correr su instancia
sola, puede hacerlo. El `.db` de `default` sigue siendo válido.

## Aislamiento de datos

### Entre alumnos (Fase 1 y Fase 2)

- Cada conexión WebSocket está asociada a **una sala** (`roomCode`) y a un
  `sessionToken` en el momento del `student.join`.
- El servidor **enruta por la asociación en el hub**, no por un campo del
  mensaje. Un alumno no puede cambiar de sala enviando un `roomCode` distinto:
  su conexión ya está atada a la sala en la que hizo join.
- El servidor **nunca** retransmite respuestas individuales de un alumno a
  otro (ADR-0007). El único dato que cruza entre alumnos es el ranking
  agregado (top 5 + posición propia).
- El `sessionToken` se genera con `crypto/rand` (UUID v4 o equivalente), no
  es predecible y no se comparte.

### Entre tenants (Fase 2)

- **Aislamiento por archivo:** `data/tenants/<tenant_id>.db`. Un tenant no
  puede leer el archivo de otro porque su repositorio solo abre el suyo.
- **Sin row-level security emulada en aplicación.** No hay una tabla global
  con columna `tenant_id` compartida. Cada tenant tiene su propio `.db`.
  Esto es más simple y más seguro que emular RLS con filtros en cada query.
- **Aislamiento de quizzes:** `quizzes/<tenant_id>/*.json`. El loader de un
  tenant no puede leer archivos de otro.

## Autenticación docente

### Fase 1 — Token estático

- `TEACHER_TOKEN` por variable de entorno.
- El docente lo ingresa en `/teacher` una vez, se guarda en `localStorage`.
- El servidor valida en el handshake WebSocket del panel docente.
- Simple, sin dependencias, suficiente para un piloto.

### Fase 2 — OAuth

- Recomendado: [`goth`](https://github.com/markbates/goth), soporta Google,
  Azure AD, GitHub y cualquier proveedor OIDC.
- Flujo: `/auth/<provider>` → callback → sesión con `teacher_id` →
  `tenant_id` resuelto desde una tabla `teacher_tenants` (o uno-a-uno si cada
  docente es su propio tenant).
- El `teacher_id` y `tenant_id` se inyectan en el `context.Context` de cada
  request HTTP y de cada conexión WebSocket.

### La interfaz `Authenticator`

```go
type Authenticator interface {
    // Authenticate recibe el token de sesión (o cookie, o header) y devuelve
    // el tenant_id asociado, o error si no es válido.
    Authenticate(ctx context.Context, token string) (tenantID string, err error)
}
```

- Fase 1: implementación `StaticToken` que devuelve `"default"` si el token
  matchea `TEACHER_TOKEN`.
- Fase 2: implementación `OAuthSession` que lee la cookie de sesión y resuelve
  `tenant_id`.

El resto del código **no sabe** qué implementación está activa. Solo usa
`Authenticator`.

## Qué se persiste y qué no

| Dato | ¿Se persiste? | Dónde | Por qué |
|---|---|---|---|
| Sala activa (respuestas, ranking, timer) | No | Memoria | Hot path (ADR-0004) |
| Participantes por partida (cantidad) | Sí | SQLite | Estadística pedagógica |
| Aciertos por pregunta | Sí | SQLite | Estadística pedagógica |
| Distribución de respuestas por opción | Sí | SQLite | Estadística pedagógica |
| Tiempo promedio de respuesta por pregunta | Sí | SQLite | Estadística pedagógica |
| `student_id` | **Nunca** | — | ADR-0005 |
| `nickname` | **Nunca** | — | ADR-0005 |
| `email` | **Nunca** | — | ADR-0005 |
| IP del alumno | **Nunca** | — | ADR-0005 |
| Identidad del docente | Fase 1: no. Fase 2: sí (OAuth) | SQLite (`teachers`) | Necesaria para multi-tenant |

## Checklist de migración a Fase 2

Cuando decidas pasar a multi-tenant, esto es lo que cambia. Nada más.

- [ ] Agregar tabla `teachers` y `teacher_tenants` (o equivalente).
- [ ] Implementar `Authenticator` con OAuth (`goth`).
- [ ] Cambiar `storage/sqlite` para abrir `data/tenants/<tenant_id>.db` en
      vez de `data/tenants/default.db` fijo.
- [ ] Cambiar `quiz` loader para leer `quizzes/<tenant_id>/*.json`.
- [ ] Agregar middleware que resuelva `tenant_id` desde la sesión y lo
      inyecte en el contexto de cada request y cada conexión WebSocket.
- [ ] Migrar datos existentes: `data/tenants/default.db` → el `.db` del
      primer tenant real.
- [ ] Actualizar el panel docente para mostrar solo quizzes y reportes del
      tenant actual.
- [ ] Actualizar tests de integración para correr con múltiples tenants.

**Lo que NO cambia:**
- `internal/domain` (lógica pura de scoring, ranking, avatar, markdown).
- `internal/room` (estado de sala en memoria).
- `internal/protocol` (mensajes WebSocket).
- `internal/client` (conexión, ping/pong, takeover).
- El cliente (HTML/CSS/JS vanilla).
- El esquema de `game_sessions` y `question_stats` (ya tienen `tenant_id`).

## Criterios para decidir el pasaje a Fase 2

No migrar antes de tiempo. Los disparadores concretos son:

1. **Más de un docente quiere usar la instancia** y compartir estadísticas
   por cátedra.
2. **Los backups por archivo se vuelven inmanejables** (>5 tenants en una
   instancia, o necesidad de backups coordinados).
3. **Un docente pide ver estadísticas agregadas** de varias cohortes suyas.
4. **El piloto validó** latencia, red y experiencia. Sin piloto exitoso, no
   hay Fase 2.

Si ninguno de estos se cumple, seguir en Modelo A es más simple, más barato
y más seguro.

## Lo que este documento NO cubre

- Modelo freemium / monetización: decisión de producto, no de arquitectura.
  Si se decide, se documenta en un ADR nuevo.
- Aislamiento entre docentes dentro de un mismo tenant (ej. co-docencia):
  no está en el alcance de Fase 2; si aparece la necesidad, se documenta.
- Cifrado en reposo del `.db` por tenant: no está en Fase 1 ni 2. Si la
  política de la facultad lo exige, se evalúa (SQLCipher u otro).
- Auditoría de accesos: no está en alcance. Si se necesita, va a un ADR.