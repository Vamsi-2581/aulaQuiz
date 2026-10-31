# Glosario

- **Sala (Room):** instancia de una partida, identificada por un código de 4
  caracteres. Vive en memoria del servidor mientras está activa.
- **Docente (Teacher):** cliente con rol de orquestador. Crea la sala, inicia
  la partida, avanza preguntas, la cierra.
- **Alumno (Student):** cliente que se une a la sala, responde preguntas y
  recibe puntaje.
- **Nickname:** identificador público del alumno dentro de la sala. Único,
  efímero, 1–20 caracteres.
- **Email institucional:** dato opcional del alumno. No se valida ni se usa
  para lookup.
- **AvatarSeed:** cadena derivada del nickname que determina el avatar.
- **SessionToken:** token emitido al alumno en el join. Permite reconectar
  dentro del período de gracia.
- **Snapshot:** mensaje `room.snapshot` con el estado completo de la sala,
  enviado al conectar o reconectar.
- **Broadcast agregado:** estrategia de emisión en la que el servidor agrega
  el estado y emite un único mensaje a todos, en lugar de retransmitir
  eventos individuales.
- **Ventana de respuesta:** intervalo durante el cual se aceptan respuestas
  para una pregunta. Definido por `startsAt` y `endsAt` del servidor.
- **Bonus por velocidad:** puntaje adicional que decrece linealmente desde el
  inicio de la ventana hasta el cierre.

## Fórmula de puntaje (RF-07)
base = 1000
bonus_max = 500
elapsed = receivedAt - startsAt (en ms)
duration = endsAt - startsAt (en ms)
ratio = clamp(elapsed / duration, 0, 1)
bonus = round(bonus_max * (1 - ratio))
score = base + bonus si la respuesta es correcta
score = 0 si es incorrecta
text


## Fórmula de avatar (ADR-0009)

h = fnv1a(nickname)
shape = h % 4 // 4 formas disponibles
color = (h >> 8) % 8 // 8 colores de paleta
initial = upper(nickname[0])

## Desempate

Cuando dos o más alumnos terminan con el mismo `score`, el orden se resuelve
así (en orden, hasta desempatar):

1. **Menor `totalElapsedCorrect`** (suma de `elapsed` de respuestas correctas,
   en milisegundos). Menos tiempo = mejor.
2. **Más respuestas correctas** (`correctCount`). A igual tiempo total, quien
   acertó más veces.
3. **Menor `joinedAt`** (el que se unió primero).
4. **`nickname` en orden lexicográfico ascendente** (desempate determinista
   final).

`correctCount` y `totalElapsedCorrect` son campos del modelo de alumno en la
sala; no se envían al cliente en `leaderboard.update`, solo se usan para
ordenar.