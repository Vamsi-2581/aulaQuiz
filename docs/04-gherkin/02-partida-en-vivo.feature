# language: es

Característica: Partida en vivo

  Antecedentes:
    Dado que existe la sala "AB12" con 140 alumnos conectados
    Y el docente está conectado en el panel

  Escenario: El docente inicia la partida
    Cuando el docente inicia la partida
    Entonces todos los alumnos reciben "question.show" con la pregunta 1
    Y la sala pasa a fase "question_open"
    Y el mensaje incluye el timestamp "endsAt"

  Escenario: Un alumno responde dentro de la ventana
    Dado que la pregunta 1 está abierta
    Cuando el alumno "Ana" selecciona la opción "b"
    Entonces recibe "answer.ack" con "accepted: true"
    Y su respuesta se registra con el timestamp del servidor

  Escenario: Un alumno responde fuera de la ventana
    Dado que la pregunta 1 se cerró
    Cuando el alumno "Ana" intenta seleccionar la opción "b"
    Entonces recibe "answer.ack" con "accepted: false" y "reason: question_closed"

  Escenario: El servidor cierra la pregunta y emite resultados
    Dado que la pregunta 1 está abierta con respuestas registradas
    Cuando el docente avanza a la siguiente pregunta
    Entonces todos los alumnos reciben "question.results"
    Y el mensaje incluye el conteo agregado por opción
    Y el mensaje incluye la opción correcta
    Y el mensaje incluye el top 5 del ranking

  Escenario: Actualización de ranking acotada
    Dado que la pregunta 1 está abierta
    Y llegan 50 respuestas en 2 segundos
    Entonces el servidor emite "leaderboard.update" como máximo 4 veces en esos 2 segundos

  Escenario: El servidor no retransmite respuestas individuales
    Dado que la pregunta 1 está abierta
    Cuando el alumno "Ana" responde "b"
    Entonces ningún otro alumno recibe un mensaje con la respuesta de "Ana"