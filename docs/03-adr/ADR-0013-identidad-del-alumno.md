# ADR-0013 — Identidad del alumno: studentId opaco, nickname no único

- **Estado:** propuesto
- **Supersede parcialmente:** ADR-0005 (sección "Decisión" y "Consecuencias negativas")
- **Refs:** RF-02, RF-03, ADR-0009, `protocolo-websocket.md`

## Contexto

ADR-0005 estableció que el nickname debe ser **único dentro de la sala**
y que un join con nickname duplicado se rechaza con `nickname_taken`.

En la práctica esto es un problema: en cualquier curso hay al menos dos
"Juan Pérez", "Sofía", "Martín" o "Flor". Rechazar el join obliga al
alumno a inventar un alias (`juanp87`, `juan_perez_2`), lo que degrada
la experiencia de join y la narración del docente, y no aporta ninguna
garantía real de identidad (no hay anti-cheating en v1 por decisión
explícita).

La identidad real del alumno ya es el `studentId` opaco que genera el
servidor. El nickname es sólo un display name.

## Decisión

Se separa **identidad** de **display name**:

- **Identidad:** `studentId` (opaco, server-generated, ej. `s_a1b2c3d4`).
  Es la clave en todas las estructuras internas (`Answers map[string]`,
  `Scores map[string]`, `Students map[string]`). No cambia durante la
  vida de la sala.
- **Display name:** `nickname` (string validado sólo por formato:
  1–20 caracteres; letras Unicode `\p{L}`, dígitos `\p{N}`, espacio,
  `-`, `_`, `.`; sin emojis ni símbolos de formato). **No requiere
  unicidad.**
- **Desambiguación:** en caso de colisión de display name
  (comparación **case-insensitive** vía `strings.EqualFold`), el
  servidor agrega un sufijo determinístico `" (N)"` al nickname del
  segundo alumno en adelante:
  - `"Juan Pérez"` → primer alumno.
  - `"Juan Pérez (2)"` → segundo.
  - `"Juan Pérez (3)"` → tercero.
- **Sufijo monotónico, no reutilizable:** si el alumno `"Juan Pérez"`
  se desconecta y su grace period expira, un nuevo `"Juan Pérez"` que
  ingrese después recibe `"Juan Pérez (N+1)"` (el siguiente valor
  disponible), no el sufijo liberado. Esto evita ambigüedad histórica
  en el reporte post-partida y en logs de observabilidad.
- **avatarSeed:** se calcula sobre el nickname **resuelto** (con
  sufijo si aplica). ADR-0009 se mantiene: mismo string → mismo seed,
  siempre. `"Ana"` y `"Ana (2)"` tienen avatares distintos.
- **`student.joined`** devuelve el nickname **resuelto**. El cliente
  lo muestra tal cual (no hace falta notificar "te cambiamos el
  nombre"; el alumno ve el sufijo).
- **Se elimina el error `nickname_taken`** del protocolo.

## Justificación

- **Minimización de datos (ADR-0005 se mantiene):** seguimos sin pedir
  identidad real (DNI, email obligatorio, cuenta). El nickname no es
  identidad; usarlo como identidad era un atajo que no resiste el caso
  de nombres repetidos, que es común.
- **El docente es el consumidor del ranking:** dos "Juan Pérez"
  empatados son difíciles de narrar en clase. El sufijo resuelve esto
  sin tocar el modelo de identidad.
- **Sufijo monotónico:** evita que el ranking histórico de una partida
  cambie de significado si alguien se desconecta y reingresa, y
  simplifica la implementación (no hace falta "liberar" sufijos).
- **Formato `" (N)"`:** es el patrón que usan Discord, Zoom, Slack
  y la mayoría de los chat. El paréntesis deja claro que es una
  desambiguación y no parte del nombre tipeado.

## Consecuencias

- **Positivas:**
  - Ningún alumno es rechazado por elegir un nickname popular.
  - El docente narra sin ambigüedad.
  - La identidad interna sigue siendo opaca, estable y server-generated.
  - El cliente no necesita manejar `nickname_taken` en el join.
- **Negativas:**
  - Un alumno puede "adivinar" quién es quién por el orden de llegada
    (quien llegó primero conserva el nombre "limpio"). Aceptable: no
    hay anti-cheating en v1.
  - Requiere mantener, por sala, un contador `map[baseLower]int` que
    crece monotónicamente mientras la sala exista. Costo O(1) por
    join; se descarta junto con la sala.
- **Compatibilidad:** supersede la exigencia de unicidad de ADR-0005.
  El resto de ADR-0005 (registro efímero, email opcional, sin
  persistencia de datos personales) **sigue vigente**.

## Detalle de implementación (no vinculante, orientativo)

Contador por sala, indexado por base-name en lowercase:

```go
// En Room
nameCounters map[string]int // "juan pérez" -> último N usado

func (r *Room) resolveNickname(raw string) string {
    base := strings.TrimSpace(raw)
    key := strings.ToLower(base)
    r.mu.Lock()
    defer r.mu.Unlock()
    n := r.nameCounters[key]
    r.nameCounters[key] = n + 1
    if n == 0 {
        return base
    }
    return fmt.Sprintf("%s (%d)", base, n+1)
}
```

Se preserva el casing del alumno que llega ("juan perez" →
"juan perez (2)", no "Juan Pérez (2)").
Alternativas consideradas

- Rechazar join con nickname_taken (ADR-0005 original): descartado por fricción y por el caso de nombres repetidos.
- Permitir duplicados textuales sin sufijo: válido, pero el leaderboard y el reporte post-partida se vuelven ambiguos para narrar.
- Pedir DNI o email obligatorio: contradice el principio de minimización y agrega fricción (ADR-0005 ya lo descarta).
- Sufijo aleatorio (hash): más difícil de leer y narrar que (N).

## Ajustes chicos derivados

**`docs/03-adr/ADR-0005-registro-efimero.md`** — sólo la línea de estado, sin tocar el cuerpo (es la práctica estándar: el cuerpo de un ADR aceptado no se edita).