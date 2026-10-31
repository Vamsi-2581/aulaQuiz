# language: es

Característica: Avatares generados localmente

  Escenario: El avatar es determinístico
    Cuando el alumno "Ana" se une a una sala
    Entonces recibe un avatarSeed
    Cuando "Ana" se reconecta
    Entonces recibe el mismo avatarSeed

  Escenario: El avatar se deriva del nickname
    Cuando un alumno se une con nickname "Ana"
    Entonces el avatarSeed es el mismo que si el nickname fuera "Ana" en otra sala

  Escenario: El cliente renderiza el avatar sin requests externos
    Dado que el cliente del alumno cargó
    Cuando se renderiza el avatar
    Entonces no se realiza ningún request a dominios distintos del servidor
    Y el avatar se compone con CSS y la inicial del nickname

  Escenario: Dos nicknames distintos pueden compartir avatar
    Cuando "Ana" y "Beto" tienen avatarSeeds que producen la misma forma y color
    Entonces ambos avatares se ven similares pero con inicial distinta
    Y no es un error