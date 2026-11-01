# Componentes

## `cmd/aulaquiz/main.go`

Punto de entrada. Lee configuración por env (`PORT`, `QUIZ_PATH`), arma el
router, monta los assets embebidos y arranca `http.Server`.

## `internal/hub`

Registro de salas activas. API mínima:

- `Create() *Room`
- `Get(code string) (*Room, bool)`
- `Delete(code string)`

Protegido por `sync.RWMutex`. En v1 una sala por código; no hay límite de
salas concurrentes en el código, pero la operación asume una activa.

## `internal/room`

Núcleo del estado de una partida. Campos principales:

- `Code string`
- `Teacher *Client`
- `Students map[string]*Client` (por `studentId`)
- `Phase` (`lobby` | `question_open` | `question_closed` | `finished`)
- `CurrentQuestion *Question`
- `Answers map[string]Answer` (por `studentId`, de la pregunta actual)
- `Scores map[string]int`
- `broadcast chan []byte`
- `mu sync.RWMutex`

Responsabilidades: aceptar joins, iniciar partida, abrir/cerrar preguntas,
registrar respuestas, emitir eventos. Delega el cálculo a `internal/domain`.

## `internal/client`

Representa una conexión WebSocket. Encapsula:

- `conn *websocket.Conn`
- `send chan []byte` (buffer acotado, descarta si se llena)
- `role` (`teacher` | `student`)
- `id`, `nickname`, `avatarSeed`, `email`

Una goroutine lee, otra escribe. El cierre siempre es ordenado por el cliente.

## `internal/domain`

Lógica pura, sin red:

- `Scoring`: `Score(correct bool, elapsed, total time.Duration) int`
- `Ranking`: ordena puntajes y devuelve top N + posición propia
- `Avatar`: `Derive(seed string) Avatar` → `{ shape, color, initial }`

## `internal/protocol`

Define los structs de mensajes, el envelope y los `type` constantes. Es el
contrato entre backend y frontend. Documentado en `protocolo-websocket.md`.

## `web/`

Assets embebidos con `//go:embed`:

- `web/index.html` — landing (elegir docente o alumno)
- `web/teacher.html` + `web/teacher.js` + `web/teacher.css`
- `web/play.html` + `web/play.js` + `web/play.css`
- `web/shared.css`, `web/shared.js`

## Dependencias permitidas

- `github.com/coder/websocket`
- Biblioteca estándar.

Cualquier otra dependencia requiere un ADR.

docs/02-arquitectura/protocolo-websocket.md
markdown

# Protocolo WebSocket

## Envelope

Todos los mensajes son texto JSON con esta forma:

```json
{ "type": "string", "ts": 1717000000000, "payload": { } }
```
- type: identificador del mensaje.
- ts: timestamp Unix ms del emisor (informativo, no autoritativo).
- payload: objeto específico del tipo.

Convención de nombres

- Cliente → Servidor: <entidad>.<acción> (student.join, answer.submit).
- Servidor → Cliente: <entidad>.<evento> (question.show, room.snapshot).

## Mensajes del alumno → servidor

### `student.join`

```json
{ "type": "student.join", "payload": {
    "roomCode": "AB12",
    "nickname": "Ana",
    "email": "ana@frba.utn.edu.ar"
}}
```
`email` es opcional (`null` o ausente). El servidor no rechaza nicknames
duplicados; en una colisión case-insensitive agrega el sufijo `(N)` al display
name.

### Respuesta exitosa: `student.joined`
```json
{ "type": "student.joined", "payload": {
    "studentId": "s_a1b2c3d4",
    "sessionToken": "tok_xxx",
    "avatarSeed": "ana-7f3a",
    "snapshot": { ...mismo payload que room.snapshot... }
}}
```
`payload.nickname` es el **display name resuelto** y puede diferir del nickname
tipeado por el usuario debido al sufijo agregado en una colisión.
`sessionToken` debe guardarse en `localStorage`. Es la única forma de
recuperar la sesión tras un corte o recarga.

### `student.reconnect`
```json
{ "type": "student.reconnect", "payload": { "sessionToken": "tok_xxx" } }
```
Respuesta: `room.snapshot`. Si el token es inválido o venció el período de gracia → `session_expired`. Si ya hay otra conexión activa con ese token, aplica takeover (ADR-0011): la conexión vieja se cierra con código 4000 y razón `session.takeover`, la nueva gana.

### `student.answer`
```json 
{ "type": "student.answer", "payload": {
    "questionId": "q3",
    "optionId": "b"
}}
```
El servidor responde `answer.ack { accepted: true|false, reason? }`.
Rechazos: `question_closed`, `invalid_option`.

## Mensajes del docente → servidor

### `teacher.create`

Crea una sala nueva. El quiz se toma del `QUIZ_PATH` cargado al arrancar el
servidor (v1 soporta un quiz global).

```json
{ "type": "teacher.create", "payload": { } }
```

### Respuesta: `teacher.created`
```json
{ "type": "teacher.created", "payload": {
    "roomCode": "AB12",
    "teacherToken": "tok_yyy",
    "snapshot": { ...mismo payload que room.snapshot... }
}}
```
El docente debe guardar `teacherToken` (localStorage) para poder reconectar.

`teacher.reconnect`
```json
{ "type": "teacher.reconnect", "payload": { "teacherToken": "tok_yyy" } }
```

Respuesta: `room.snapshot`. No aplica grace period. El `teacherToken` es válido
mientras la sala exista. Si la sala fue cerrada (`teacher.close`) →
`session_expired`. Si el docente ya tenía otra conexión activa, aplica takeover
(ADR-0011).

`teacher.start`
Inicia la partida (lobby → question_open con la primera pregunta).

`teacher.advance`
Cierra la pregunta actual y avanza a la siguiente, o a `finished` si era la última.

`teacher.close`
Cierra la sala y descarta el estado.

## Mensajes servidor → cliente (broadcast)

### Formato de texto enriquecido

Los campos de texto de pregunta y opciones (`question.text`, `options[].text`) **no son strings**: son arrays de nodos AST que el cliente renderiza sin parsear markdown (ADR-0010). Formato:

- `{"t": "text", "c": "..."}` — texto plano; `\n` se renderiza como `<br>`.
- `{"t": "bold", "c": "..."}`
- `{"t": "italic", "c": "..."}`
- `{"t": "code", "c": "..."}` — inline code
- `{"t": "codeblock", "c": "..."}` — bloque de código; `\n` preservado
- `{"t": "link", "c": "...", "href": "https://..."}` — `href` validado
  server-side; solo `http` y `https`

Sin anidamiento en v1. Los nodos contienen texto plano en `c`, nunca HTML.

Los nicknames y títulos son texto plano, **no** admiten markdown.

### `room.snapshot`

Emitido al conectar o reconectar. Contiene todo el estado necesario para
renderizar. Es la única fuente de verdad para el cliente tras una reconexión.

```json
{ "type": "room.snapshot", "payload": {
    "roomCode": "AB12",
    "phase": "question_open",
    "question": {
      "id": "q3", "index": 3, "total": 10,
      "text": [ {"t":"text","c":"Dado "}, {"t":"code","c":"x=5"}, ... ],
      "options": [
        {"id":"a","text":[{"t":"code","c":"ls"}]},
        ...
      ],
            "startsAt": 1717000000000,
      "endsAt": 1717000030000
    },
    "self": { "studentId": "s_abc", "score": 1240, "rank": 12 },
    "leaderboard": [{ "nickname": "Ana", "score": 1500, "rank": 1 }, ...],
    "participants": 200
}}
```
Para docente, `self` es `{ "role": "teacher" }`.

### `question.show`
Igual a la parte `question` del snapshot, emitido a todos. Incluye `startsAt`
(Unix ms) junto a `endsAt`.

### `question.results`
```json
{ "type": "question.results", "payload": {
    "questionId": "q3",
    "correctOptionId": "b",
    "counts": { "a": 12, "b": 98, "c": 20, "d": 10 },
    "leaderboardTop": [ ... ]
}}
```

### `leaderboard.update`
Emitido cada ≤500 ms durante `question_open`. Top 5 + posición propia.

### `session.finished`
```json
{ "type": "session.finished", "payload": {
    "podium": [ {"nickname":"Ana","score":1500}, ... ],
    "self": { "score": 1240, "rank": 12 }
}}
```

### `session.takeover`
Enviado a la conexión que pierde una sesión por takeover (ADR-0011). El servidor también cierra la conexión con WebSocket close code 4000 y razón `session.takeover`.
```json
{ "type": "session.takeover", "payload": {
    "reason": "nueva_conexion_detectada"
}}
```
El cliente que lo recibe debe dejar de reconectar y mostrar un aviso.

### `error`
```json
{ "type": "error", "payload": { "code": "session_expired", "message": "..." } }
```

### `teacher.disconnected` (broadcast a alumnos)
Cuando el docente pierde la conexión, los alumnos reciben este evento. El juego **no se pausa** (el timer sigue). Cuando el docente reconecta, recibe `room.snapshot` con el estado vigente.
```json
{ "type": "teacher.disconnected", "payload": { "graceSecs": 60 } }
```

### `teacher.reconnected` (broadcast a alumnos)
```json
{ "type": "teacher.reconnected", "payload": { } }
```

### Tabla códigos de error
| `code` | Significado |
|---|---|
| `room_not_found` | El código de sala no existe |
| `room_full` | La sala alcanzó el máximo de alumnos (200) |
| `nickname_invalid` | Fuera de 1–20 caracteres o con caracteres no permitidos |
| `session_expired` | Token de reconexión inválido o vencido |
| `question_closed` | Respuesta fuera de la ventana |
| `invalid_option` | Opción inexistente para la pregunta |
| `not_teacher` | Acción docente desde conexión de alumno |

## Modelo de identidad

- `studentId` = identidad.
- `nickname` = display, no único.
- `sessionToken` = reconnect.

## Reglas de robustez

Buffer de envío por cliente: 32 mensajes. Si se llena, se descartan los mensajes de ranking (no críticos) antes que los eventos de control.

Ping/pong cada 20 s. Sin pong en 40 s → desconexión → período de gracia 60 s.

Tamaño máximo de mensaje entrante: 4 KB.

## Validación de nickname

- Longitud: 1–20 caracteres después de `strings.TrimSpace`.
- Caracteres permitidos: letras Unicode (`\p{L}`), dígitos (`\p{N}`),
  espacio, `-`, `_`, `.`. **No** se permiten emojis ni símbolos de formato.
- Se rechaza si queda vacío tras el trim.
- El nickname es **texto plano**: no se interpreta como markdown. El cliente
  lo renderiza siempre con `textContent`.