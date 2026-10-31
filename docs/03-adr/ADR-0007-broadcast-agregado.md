# ADR-0007 — Broadcast agregado, no retransmisión individual

- **Estado:** aceptado

## Contexto

En un juego con 140 alumnos, si cada respuesta individual se retransmite a
todos, se generan 140 × 140 = 19.600 mensajes por pregunta, más los eventos
de ranking. Eso satura al servidor y, sobre todo, la red del alumno (que ya
está compartida con Zoom).

## Decisión

El servidor **agrega** el estado y emite:
- **Eventos de control** (inicio/fin de pregunta, resultado agregado, podio)
  a todos los clientes, una sola vez.
- **Actualizaciones de ranking** como máximo cada **500 ms** durante una
  pregunta abierta, con top 5 + posición propia.
- **Nunca** retransmite respuestas individuales de un alumno a otros.

## Justificación

- Reduce el tráfico en órdenes de magnitud.
- El alumno no necesita saber qué respondió cada compañero en tiempo real;
  solo necesita su propio feedback y el ranking.
- El resultado agregado por opción se envía al cerrar la pregunta, no en cada
  respuesta.

## Consecuencias

- Positivas: menor carga de red y de CPU en el cliente.
- Negativas: el ranking tiene hasta 500 ms de latencia visual. Aceptable e
  imperceptible en el contexto de una clase.