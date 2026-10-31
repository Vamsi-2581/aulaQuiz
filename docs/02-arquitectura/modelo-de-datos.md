# Modelo de datos

Todo en memoria. No hay persistencia. Al cerrar una sala, sus datos se descartan.

## `Room`

```go
type Room struct {
    Code         string
    Teacher      *Client
    Students     map[string]*Client  // key: studentId
    Phase        Phase               // lobby | question_open | question_closed | finished
    Quiz         *Quiz
    CurrentIndex int
    CurrentQuestion *Question
    Answers      map[string]Answer   // key: studentId, de la pregunta actual
    Scores       map[string]int      // key: studentId
    StartedAt    time.Time
    QuestionEndsAt time.Time
    broadcast    chan []byte
    mu           sync.RWMutex
}

Client
go

type Client struct {
    ID          string       // s_<8 hex> o t_<8 hex>
    Role        Role         // teacher | student
    Nickname    string
    Email       string       // opcional, vacío si no se proveyó
    AvatarSeed  string       // derivado del nickname
    SessionToken string      // solo alumnos
    Conn        *websocket.Conn
    Send        chan []byte
    ConnectedAt time.Time
    LastSeen    time.Time
}

Question / Quiz
go

type Quiz struct {
    ID        string
    Title     string
    Questions []Question
}

type Question struct {
    ID            string
    Text          string
    Options       []Option   // 2 a 4 opciones
    CorrectID     string
    DurationMs    int        // ventana de respuesta
}

type Option struct {
    ID   string
    Text string
}

Answer
go

type Answer struct {
    StudentID string
    OptionID  string
    At        time.Time  // reloj del servidor
    Elapsed   time.Duration
}

Índices y búsquedas

    Alumnos por studentId: mapa directo.

    Alumnos por nickname: mapa auxiliar para detectar duplicados en join.

    Alumnos por sessionToken: mapa auxiliar para reconexión.

    No se indexa por email: es opcional y no se usa para lookup.

Ciclo de vida

    hub.Create() → room vacía.

    teacher.join → setea Teacher.

    student.join × N → llena Students.

    teacher.start → Phase = question_open, CurrentIndex = 0.

    ... preguntas ...

    teacher.advance en la última → Phase = finished, emite podio.

    teacher.close → hub.Delete(code), conexiones cerradas, memoria liberada.