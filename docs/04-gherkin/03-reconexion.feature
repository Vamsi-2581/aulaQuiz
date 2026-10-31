# language: es

Característica: Reconexión tras pérdida de conexión

  Antecedentes:
    Dado que existe la sala "AB12" con la pregunta 3 abierta
    Y el alumno "Ana" tiene un sessionToken válido y 1240 puntos

  Escenario: El alumno reconecta dentro del período de gracia
    Dado que la conexión de "Ana" se cortó hace 30 segundos
    Cuando "Ana" reconecta con su sessionToken
    Entonces recibe "room.snapshot"
    Y el snapshot incluye la pregunta 3, el "endsAt" original y su puntaje 1240
    Y "Ana" puede seguir respondiendo la pregunta 3

  Escenario: El alumno reconecta después del período de gracia
    Dado que la conexión de "Ana" se cortó hace 90 segundos
    Cuando "Ana" intenta reconectar con su sessionToken
    Entonces recibe error "session_expired"
    Y debe volver a unirse con un nickname

  Escenario: Reconexión durante el lobby
    Dado que la sala está en fase "lobby"
    Y "Ana" se desconectó hace 20 segundos
    Cuando "Ana" reconecta
    Entonces recibe "room.snapshot" con fase "lobby"
    Y aparece en la lista de participantes

  Escenario: El servidor mantiene la sesión viva 60 segundos
    Dado que "Ana" se desconectó
    Cuando pasan 59 segundos sin reconexión
    Entonces el servidor todavía conserva la sesión de "Ana"
    Cuando pasan 61 segundos
    Entonces el servidor descarta la sesión de "Ana"