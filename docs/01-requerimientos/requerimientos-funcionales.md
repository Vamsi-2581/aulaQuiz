# Requerimientos funcionales

## RF-01 — Crear sala (docente)

El docente abre la aplicación, crea una sala y obtiene un **código de 4 caracteres**
y un **token de docente**. El código se comparte por el chat de Zoom.

## RF-02 — Unirse a sala (alumno)

El alumno ingresa el código y se registra con:
- **Nickname** (obligatorio, 1–20 caracteres, único dentro de la sala).
- **Email institucional** (opcional, no se valida).

El registro es **efímero**: los datos viven solo mientras la sala existe y se
descartan al cerrarse. No hay cuentas.

## RF-03 — Avatar generado

Cada alumno recibe un avatar **generado localmente** a partir de un hash de su
nickname: combinación determinística de forma + color + inicial. No hay subida
de imágenes ni requests a servicios externos.

## RF-04 — Iniciar partida

El docente, desde su panel, inicia la partida. Todos los alumnos conectados
reciben el evento y pasan a la primera pregunta.

## RF-05 — Pregunta en vivo

Para cada pregunta:
- El servidor emite el texto, las opciones y un **timestamp de fin** (`endsAt`).
- El cliente calcula el tiempo restante localmente para animar la barra.
- El alumno selecciona una opción; puede cambiarla hasta que el servidor marque
  el cierre.
- El servidor decide si la respuesta es válida según su propio reloj.

## RF-06 — Resultados por pregunta

Al cerrar la pregunta, el servidor emite el conteo agregado por opción, la
opción correcta y el top 5 del ranking. El cliente muestra el resultado y el
puntaje propio.

## RF-07 — Puntaje

El puntaje por respuesta correcta se calcula en el servidor:
`base + bonus_velocidad`, donde `bonus_velocidad` decrece linealmente desde el
inicio de la ventana hasta el cierre. Respuesta incorrecta: 0 puntos.
Ver `docs/07-varios/glosario.md` para la fórmula exacta.

## RF-08 — Ranking en vivo

El cliente muestra el top 5 y la posición propia. El ranking se actualiza
**como máximo cada 500 ms** o al cierre de cada pregunta (ver ADR-0007).

## RF-09 — Fin de partida y podio

Al terminar la última pregunta, el servidor emite el podio (top 3) y la
posición final de cada alumno. El cliente muestra animación de podio.

## RF-10 — Reconexión

Si un alumno pierde la conexión, al reconectar con su token de sesión recupera
su estado (puntaje, pregunta actual, tiempo restante) sin perder progreso.
El servidor mantiene la sesión viva **60 segundos** tras la desconexión.

## RF-11 — Cierre de sala

El docente cierra la sala. Todos los clientes reciben el evento, se muestra un
mensaje final y los datos de la sala se descartan del servidor.

## RF-12 — Markdown en preguntas y opciones

Las preguntas y opciones admiten un subconjunto de Markdown (ADR-0010).
El servidor parsea a AST al cargar el quiz; el cliente renderiza el AST
construyendo nodos DOM. El string Markdown original no se envía al cliente.

## RF-13 — Validación del quiz al arrancar

Si el archivo de quiz tiene errores de estructura o de sintaxis Markdown, el
servidor no arranca y emite un mensaje claro con la ubicación del error
(`formato-quiz.md`).

## RF-14 — Límite de sala

La sala admite hasta **200 alumnos** más el docente. Un join número 141
recibe `error { code: "room_full" }`.

## RF-15 — Takeover de sesión

Una nueva conexión con un `sessionToken` válido toma el control de la sesión
(ADR-0011). La conexión anterior se cierra con código 4000 y evento
`session.takeover`. El cliente que pierde la sesión deja de reconectar y
muestra un aviso.

## RF-16 — Docente desconectado

Si el docente pierde la conexión durante una partida, el juego **no se pausa**.
Los alumnos reciben `teacher.disconnected`. Al reconectar, el docente recibe
`room.snapshot` con el estado vigente y puede continuar. Los alumnos reciben
`teacher.reconnected`.