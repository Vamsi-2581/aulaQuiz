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