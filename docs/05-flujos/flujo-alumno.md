# Flujo del alumno

## Entrada

1. Recibe por Zoom el link o el código.
2. Abre `/play` en el navegador.
3. Ingresa código, nickname, y opcionalmente email institucional.
4. Click en "Entrar".

## En sala

1. Ve un avatar generado, su nickname y la lista de compañeros.
2. Espera el inicio de la partida.

## Por pregunta

1. Aparece la pregunta con la barra de tiempo animada.
2. Hace click en una opción (puede cambiarla hasta que se cierre).
3. La opción seleccionada se resalta con transición CSS.
4. Al cerrar la ventana, ve feedback: correcta/incorrecta, su puntaje, el top 5.

## Fin

1. Ve el podio animado.
2. Ve su posición final.
3. La pantalla queda en estado final hasta que el docente cierre la sala.

## Estados del cliente alumno

    [join] --entrar--> [lobby] --question.show--> [answering]
                                                       |
                                          question.results
                                                       v
                                                   [feedback]
                                                       |
                                          (siguiente pregunta)
                                                       v
                                                   [answering] ...
                                                       |
                                          session.finished
                                                       v
                                                    [podium]

## Desconexión

En cualquier estado, si se pierde la conexión:
- Se muestra un overlay "Reconectando..." (sin bloquear el render).
- Se reintenta con backoff: 500 ms, 1 s, 2 s, 4 s, 5 s (tope).
- Al reconectar, se reemplaza el estado local con el `room.snapshot` recibido.

## Restricciones del cliente

- Sin animaciones que usen `box-shadow` o `filter` en loop (caras en CPU).
- Solo `transform` y `opacity` en animaciones continuas.
- `prefers-reduced-motion`: desactiva animaciones no esenciales.