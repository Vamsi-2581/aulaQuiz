# ADR-0006 — Temporizador autoritativo en el servidor

- **Estado:** aceptado

## Contexto

En un juego con bonus por velocidad, el reloj del cliente no es confiable:
puede estar desincronizado, puede ser manipulado, y en una red congestionada
el tiempo de viaje del mensaje varía.

## Decisión

El servidor es la **única fuente de verdad** para el tiempo:
- Al abrir una pregunta, emite `startsAt` y `endsAt` (timestamps del servidor).
- El cliente calcula el tiempo restante localmente **solo para animar** la
  barra de progreso.
- La validez de una respuesta la decide el servidor según el timestamp en
  que **recibió** el mensaje, no el que envió el cliente.
- El cliente puede incluir un `clientTs` informativo, pero el servidor lo
  ignora para el cálculo.

## Justificación

- Evita discusiones sobre "mi reloj decía que faltaba 1 segundo".
- El bonus por velocidad se calcula sobre `endsAt - receivedAt`, consistente
  para todos.
- El cliente puede animar con precisión aceptable usando la diferencia entre
  `Date.now()` local y `endsAt` recibido (asumiendo desfase de reloj menor a
  ~1 s; en la práctica es suficiente para una barra visual).

## Consecuencias

- Positivas: consistencia, imposibilidad de manipular el tiempo desde el cliente.
- Negativas: si la red del alumno tiene 3 s de latencia, su respuesta llega
  tarde aunque él haya hecho clic a tiempo. Aceptable: ese alumno tiene un
  problema de red mayor que el juego.