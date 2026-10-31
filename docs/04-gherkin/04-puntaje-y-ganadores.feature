# language: es

Característica: Puntaje, ranking y ganadores

  Antecedentes:
    Dado que existe la sala "AB12" con la pregunta 1 abierta
    Y la ventana de respuesta es de 20 segundos

  Escenario: Respuesta correcta y rápida otorga bonus
    Cuando el alumno "Ana" responde correctamente a los 2 segundos
    Entonces recibe puntaje base más bonus por velocidad
    Y el puntaje es mayor que si hubiera respondido a los 10 segundos

  Escenario: Respuesta incorrecta no otorga puntos
    Cuando el alumno "Beto" responde incorrectamente
    Entonces su puntaje no cambia

  Escenario: Bonus decrece linealmente
    Cuando el alumno "Ana" responde correctamente a los 2 segundos
    Y el alumno "Caro" responde correctamente a los 10 segundos
    Entonces el bonus de "Ana" es mayor que el de "Caro"
    Y ambos reciben el puntaje base

  Escenario: Ranking se actualiza durante la partida
    Dado que la pregunta 1 está abierta
    Cuando "Ana" y "Beto" responden correctamente
    Entonces el ranking muestra a ambos en el top 5 si están entre los mejores
    Y cada alumno ve su posición propia

  Escenario: Podio al finalizar la partida
    Dado que la partida tiene 10 preguntas
    Cuando el docente avanza después de la pregunta 10
    Entonces todos los alumnos reciben "session.finished"
    Y el mensaje incluye el podio con los 3 primeros
    Y cada alumno ve su posición final

  Escenario: Empate se resuelve por tiempo acumulado
    Dado que "Ana" y "Beto" tienen el mismo puntaje
    Cuando se calcula el podio
    Entonces el que acumuló menor tiempo total de respuesta queda primero