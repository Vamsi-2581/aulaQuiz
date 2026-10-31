# language: es

Característica: Sala y registro de alumnos

  Antecedentes:
    Dado que el servidor está corriendo
    Y el docente tiene un quiz cargado con 10 preguntas

  Escenario: El docente crea una sala
    Cuando el docente abre la aplicación y crea una sala
    Entonces recibe un código de 4 caracteres
    Y recibe un token de docente
    Y la sala queda en fase "lobby"

  Escenario: Un alumno se une con nickname
    Dado que existe la sala "AB12" en fase "lobby"
    Cuando un alumno se une con nickname "Ana" y sin email
    Entonces recibe un sessionToken
    Y recibe un avatarSeed derivado de "Ana"
    Y el docente ve a "Ana" en la lista de participantes

  Escenario: Un alumno se une con email institucional opcional
    Dado que existe la sala "AB12" en fase "lobby"
    Cuando un alumno se une con nickname "Beto" y email "beto@frba.utn.edu.ar"
    Entonces el join es exitoso
    Y el email no se usa para ningún lookup

  Escenario: Nickname duplicado es rechazado
    Dado que existe la sala "AB12" con un alumno "Ana"
    Cuando otro alumno intenta unirse con nickname "Ana"
    Entonces recibe error "nickname_taken"
    Y no se agrega a la sala

  Escenario: Nickname vacío es rechazado
    Dado que existe la sala "AB12"
    Cuando un alumno intenta unirse con nickname ""
    Entonces recibe error "nickname_invalid"

  Escenario: Código de sala inexistente
    Cuando un alumno intenta unirse a la sala "ZZZZ"
    Entonces recibe error "room_not_found"

  Escenario: Cierre de sala descarta los datos
    Dado que existe la sala "AB12" con alumnos conectados
    Cuando el docente cierra la sala
    Entonces todos los clientes reciben el cierre
    Y el estado de la sala se descarta de la memoria