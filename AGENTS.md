# AGENTS.md

Guía canónica para agentes de IA (y humanos apurados) que contribuyan a este repo.
Si sos un agente y algo de acá contradice tu intuición o tu entrenamiento: **gana este archivo**.

Este documento **no reemplaza** a `docs/`. Lo complementa con restricciones duras
que no deben violarse sin discusión previa. Las decisiones arquitectónicas están
en `docs/03-adr/`; si necesitás cambiar una, leé la sección "Cuándo crear un ADR".

---

## 1. Contexto del proyecto (leer antes de tocar código)

`aulaquiz` es una alternativa libre y autoalojable a herramientas de quiz en vivo
(tipo Wayground/Quizizz), diseñada **específicamente** para el escenario:

- **Clase online**, alumnos y docente conectados por Zoom.
- **200 alumnos simultáneos** en una sola sala.
- **Un servidor único**, sin escalado horizontal.
- **Cliente ultraliviano**, porque Zoom ya consume 1–1.5 GB de RAM en la máquina del alumno.
- **Sin anti-cheating, sin cuentas, sin persistencia**.

El objetivo explícito es **superar a Wayground en este escenario puntual**, no
igualarlo en features. Toda contribución debe juzgarse contra ese objetivo.

---

## 2. Restricciones duras (no cambiar sin ADR)

Estas son **cerradas**. No las modifiques, no las "mejores", no las esquives
con una capa intermedia. Si creés que una debe cambiar, abrí un issue y un ADR
antes de escribir código.

| # | Restricción | ADR |
|---|---|---|
| H1 | Backend en **Go** | ADR-0001 |
| H2 | Transporte en tiempo real por **WebSocket** (`github.com/coder/websocket`) | ADR-0002 |
| H3 | Frontend **sin frameworks ni build step**. HTML + CSS + JS vanilla | ADR-0003 |
| H4 | **Sin Redis, sin DB, sin broker**. Estado en memoria del proceso | ADR-0004 |
| H5 | Registro **efímero** (nickname obligatorio, email opcional, sin persistencia) | ADR-0005 |
| H6 | Temporizador **autoritativo en el servidor** | ADR-0006 |
| H7 | **Broadcast agregado**, nunca retransmisión individual de respuestas | ADR-0007 |
| H8 | Animaciones **solo con CSS nativo** (`transform`/`opacity`) | ADR-0008 |
| H9 | Avatares **derivados determinísticamente del nickname**, sin assets ni requests externos | ADR-0009 |
| H10 | Persistencia de estadísticas en SQLite, **nunca en el hot path** | ADR-0012 |
| H11 | `tenant_id` en el esquema desde Fase 1, valor `"default"` | ADR-0012 |
| H12 | Ningún dato de alumno se persiste. Ni ID, ni nickname, ni email, ni IP | ADR-0005 + ADR-0012 |

---

## 3. Patrones prohibidos (do not do)

Si te encontrás queriendo hacer alguna de estas cosas, **detenete y abrí un issue**:

### Frontend
- ❌ Agregar React, Vue, Svelte, Angular, Preact, Solid, Alpine, jQuery, Lit o cualquier framework/librería de UI.
- ❌ Agregar build step (Webpack, Vite, esbuild, Rollup, Parcel, Babel).
- ❌ Referenciar CDNs externos (`unpkg`, `jsdelivr`, `cdnjs`, Google Fonts, DiceBear, Gravatar).
- ❌ Agregar service workers, `SharedArrayBuffer`, `WebTransport`, o cualquier API experimental.
- ❌ Animar `width`, `height`, `top`, `left`, `margin`, `padding`, `box-shadow` o `filter` en loops continuos (provoca reflow/layout, mata CPU en gama baja).
- ❌ Cargar fuentes web externas. Usar `system-ui` o la stack del sistema.
- ❌ Usar librerías de Markdown en el cliente (`marked`, `markdown-it`, `snarkdown`,
  `micromark`, etc.). El AST ya viene parseado del servidor (ADR-0010). El
  renderer propio (`web/render-ast.js`) **solo** crea nodos con
  `document.createTextNode` y `document.createElement`. Nunca `innerHTML`,
  ni siquiera con el output del renderer.

### Backend
- ❌ Agregar dependencias fuera de la biblioteca estándar y `github.com/coder/websocket`.
- ❌ Usar `unsafe` sin justificación explícita en un ADR.
- ❌ Agregar Redis, Postgres, SQLite, MongoDB, NATS, Kafka, RabbitMQ, o cualquier almacenamiento/servicio externo.
- ❌ Levantar múltiples procesos (microservicios, sidecars, workers separados).
- ❌ Persistir datos a disco (archivos, logs rotados, ni siquiera temporales).
- ❌ Agregar autenticación persistente, OAuth, JWT, sesiones en DB, ni gestión de usuarios.
- ❌ Agregar telemetría, analytics, o envío de eventos a terceros.
- ❌ Agregar `go.uber.org/zap`, `logrus`, `zerolog` u otro logger estructurado. Usar `log/slog` o `log` estándar.
- ❌ Agregar routers HTTP de terceros (chi, gin, echo, fiber). Usar `net/http` estándar.
- ❌ Agregar WebRTC, gRPC, GraphQL, SSE. El transporte es WebSocket, punto.
- ❌ Implementar anti-cheating de cualquier tipo (detección de foco, bloqueo de copy/paste, verificación de identidad).
- ❌ Construir queries SQL por concatenación de strings. Toda query usa
  prepared statements de `database/sql` con placeholders `?`. Nunca
  `fmt.Sprintf` para SQL.
- ❌ Tocar SQLite desde el hot path del juego (respuestas, timer, ranking).
  SQLite se toca solo en bordes: al cerrar sala y al generar reportes.
- ❌ Persistir `student_id`, `nickname`, `email`, `ip` o cualquier dato que
  identifique a un alumno. Solo agregados por pregunta.
- ❌ Usar `tenant_id` provisto por el cliente. El `tenant_id` siempre viene
  del `context.Context`, inyectado por el middleware a partir de la sesión
  autenticada (o `"default"` en Fase 1).
- ❌ Agregar `ORM` (GORM, ent, sqlc, etc.). `database/sql` + prepared
  statements es suficiente y no oculta el SQL.

### Proceso
- ❌ Refactorizar código fuera del alcance del PR. **Scope creep es motivo de rechazo.**
- ❌ Cambiar el protocolo WebSocket sin actualizar `docs/02-arquitectura/protocolo-websocket.md`.
- ❌ Cambiar comportamiento observable sin actualizar la feature Gherkin correspondiente.
- ❌ Agregar features fuera de `docs/01-requerimientos/alcance.md`.
- ❌ Dejar `TODO`, `FIXME`, `XXX` sin un issue que los referencie (`// TODO(#123): ...`).
- ❌ Saltar tests "porque es un cambio chico".
- ❌ Commitear secretos, tokens, `.env`, binarios compilados, ni `node_modules` (aunque no haya node, por las dudas).
- ❌ Hacer `git push --force` a ramas compartidas (`main`, ramas de otros).

---

## 4. Patrones obligatorios

- ✅ **Tests unitarios** para toda función nueva en `internal/domain/` (lógica pura: scoring, ranking, avatar).
- ✅ **Tests de integración** para todo mensaje WebSocket nuevo o modificado (usando un servidor de prueba en `httptest`).
- ✅ **Feature Gherkin** en `docs/04-gherkin/` para todo comportamiento observable nuevo.
- ✅ **ADR** en `docs/03-adr/` para toda decisión arquitectónica nueva (ver sección 6).
- ✅ **Actualizar la doc** correspondiente en el mismo PR que el código.
- ✅ **Commit messages** en formato Conventional Commits (`feat(room): ...`, `fix(ws): ...`, `docs(adr): ...`).
- ✅ **`gofmt`** aplicado. `go vet ./...` sin warnings. `go test ./...` verde antes de pushear.
- ✅ **Respetar `prefers-reduced-motion`** en toda animación nueva.
- ✅ **Accesibilidad mínima**: contraste suficiente, `aria-label` en botones sin texto, navegación por teclado en el cliente alumno.
- ✅ **Toda escritura a SQLite** va en una transacción explícita.
- ✅ **Toda lectura a SQLite** filtra por `tenant_id` del contexto. Nunca
  hay `SELECT` sin filtro de tenant.
- ✅ **Todo acceso a datos** pasa por una interfaz de repositorio en
  `internal/domain` (ej. `StatsRepository`). La implementación SQLite vive
  en `internal/storage/sqlite`.
- ✅ **Migraciones** son archivos embebidos con `//go:embed`, aplicados al
  arrancar, idempotentes y versionados con `PRAGMA user_version`.

---

## 5. Convenciones de código y estructura

### Go
- Paquetes en `internal/`, no en `pkg/`.
- Nombres de paquete en singular, cortos, sin guiones ni underscores.
- Errores con `fmt.Errorf("contexto: %w", err)` para envolver.
- `context.Context` como primer parámetro de funciones que hacen I/O.
- Sin `init()`. Toda inicialización explícita en `main.go` o en constructores `NewXxx`.
- Sin variables globales mutables. El estado vive en structs inyectados.
- Dominio (`internal/domain`) **sin imports de red, HTTP, ni WebSocket**. Debe ser testeable con `go test` puro.

### Estructura de archivos

| Qué querés agregar | Dónde va |
|---|---|
| Nueva lógica de puntaje | `internal/domain/scoring.go` + `scoring_test.go` |
| Nuevo mensaje WebSocket | `internal/protocol/messages.go` + doc en `protocolo-websocket.md` + feature Gherkin |
| Nuevo handler HTTP | `internal/hub/` o `cmd/aulaquiz/main.go` (según corresponda) |
| Nueva pantalla del cliente | `web/<nombre>.html` + `.css` + `.js` |
| Nueva decisión arquitectónica | `docs/03-adr/ADR-NNNN-titulo.md` (numeración incremental) |

### Frontend
- Un archivo `.html`, un `.css`, un `.js` por pantalla. Sin bundling.
- Helpers compartidos en `web/shared.js` (máximo 200 líneas; si crece, discutir).
- CSS: variables en `:root`, mobile-first no (desktop prioritario en v1), pero sin romper en mobile.
- Sin `innerHTML` con datos del usuario (XSS). Usar `textContent` o `createElement`.

---

## 6. Cuándo crear un ADR

Creá un ADR **antes de escribir código** cuando:

- Agregás o cambiás una dependencia.
- Cambiás la forma en que se comunican cliente y servidor.
- Agregás una capa (caché, cola, worker, etc.).
- Cambiás el modelo de persistencia (aunque sea "no persistir").
- Introducís un patrón de concurrencia no trivial (más allá de goroutine por cliente + mutex por sala).
- Cambiás el formato del quiz o del puntaje.

**Formato**: copiá `docs/03-adr/ADR-0001-lenguaje-backend-go.md` como plantilla. Un ADR aceptado no se edita: se supersede con uno nuevo que lo referencia. Estado posible: `propuesto`, `aceptado`, `rechazado`, `obsoleto`, `supersedido por ADR-NNNN`.

---

## 7. Cómo verificar tus cambios antes de pushear

```bash
gofmt -l .                    # debe imprimir vacío
go vet ./...                  # debe pasar
go test ./...                 # debe pasar
go build ./...                # debe compilar
```

Además:
- Abrí el cliente en el navegador y probá el flujo completo tocado.
- Verificá que el bundle gzipped siga por debajo de 150 KB (`make size` cuando exista; mientras, a ojo).
- Revisá que no agregaste requests a dominios externos (DevTools → Network).

---

## 8. Cuando no estés seguro

1. **Buscá primero** en `docs/` (especialmente `03-adr/` y `01-requerimientos/alcance.md`).
2. **Si la respuesta no está**, abrí un issue con la pregunta concreta y la opción que proponés.
3. **No implementes** una solución que contradiga una restricción dura aunque "funcione".
4. **No expandas el alcance** del issue que estás resolviendo. Si detectás algo que debería hacerse, creá un issue separado y mencioná el actual.

Si sos un agente y el usuario te pide algo que viola una restricción dura, **explicá la restricción, citá el ADR, y ofrecé la alternativa** que sí cumple. No implementes en silencio algo que viola este archivo.

---

## 9. Recordatorio de alcance (v1)

**En alcance**: modo online, 200 alumnos, multiple-choice, nicknames efímeros, avatares generados, ranking, podio, reconexión.

**Fuera de alcance**: modo presencial, anti-cheating, cuentas, historial, analytics, editor visual, preguntas abiertas, imágenes/audio, múltiples docentes, salas concurrentes, móvil nativo, i18n.

Si una idea tuya cae en "fuera de alcance", **no la implementes en v1**. Anotala en `docs/07-varios/roadmap-mvp.md` como candidata a v2 vía PR de doc.

**Persistencia en v1:** estadísticas agregadas por partida (participantes,
aciertos por pregunta, distribución, tiempo promedio). **Nunca** datos de
alumnos. El hot path del juego **no** toca SQLite.

**Autenticación en v1:** token estático de docente por variable de entorno
(`TEACHER_TOKEN`). OAuth para docentes queda para Fase 2 (ver `modelo-tenant.md`).

---

## 10. Herramientas que leen este archivo

- OpenAI Codex / ChatGPT coding agents: leen `AGENTS.md` en la raíz.
- Cursor: soporta `AGENTS.md` (o `.cursorrules` apuntando acá).
- Claude Code: lee `CLAUDE.md` (crear symlink o archivo corto que diga "ver AGENTS.md").
- GitHub Copilot Workspace: lee `.github/copilot-instructions.md` (crear symlink o archivo corto que diga "ver AGENTS.md").

**Canónico:** este archivo. Los demás son punteros. Si hay divergencia, gana `AGENTS.md`.

## 11. Markdown (ADR-0010)

El subconjunto de Markdown soportado está en `docs/02-arquitectura/formato-quiz.md`.
Si un quiz o mensaje necesita un constructo no soportado (listas, imágenes,
tablas, anidamiento, HTML crudo), **no lo agregues al parser en silencio**:
abrí un ADR que supere ADR-0010.

El parser server-side (`internal/markdown`) es el único lugar donde se acepta
markdown. El cliente **nunca** ve markdown crudo: ve AST.

## 12. Aislamiento y multi-tenant

Toda decisión que toque persistencia, autenticación o aislamiento de datos
debe leer primero `docs/02-arquitectura/modelo-tenant.md`. Ese documento es
la referencia canónica sobre:

- Qué es un tenant en aulaQuiz.
- Por qué Fase 1 es single-tenant con `tenant_id = "default"`.
- Cómo se migra a multi-tenant sin reescribir.
- Dónde se hace el aislamiento (por archivo SQLite por tenant).
- Qué se persiste y qué nunca se persiste.

Reglas duras derivadas de ese documento:

- El `tenant_id` **nunca** viene del cliente. Viene del contexto.
- El aislamiento entre alumnos se hace **por asociación de conexión a la
  sala**, no por un campo del mensaje. Un alumno no puede cambiar de sala
  enviando un `roomCode` distinto.
- Los mensajes WebSocket nunca retransmiten datos de un alumno a otro, salvo
  el ranking agregado (ADR-0007).
- Toda nueva tabla en SQLite incluye `tenant_id` desde el día uno, aunque
  en Fase 1 valga `"default"`.