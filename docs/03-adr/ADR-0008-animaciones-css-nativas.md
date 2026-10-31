# ADR-0008 — Animaciones con CSS nativo

- **Estado:** aceptado

## Contexto

Necesitamos que el juego "enganche" visualmente sin cargar librerías de
animación (GSAP, Framer Motion, Lottie) que sumarían peso y CPU en un cliente
que debe ser invisible frente a Zoom.

## Decisión

Todas las animaciones se implementan con **CSS nativo**:
- `@keyframes` para animaciones continuas (barra de tiempo, pulso de "esperando").
- `transition` para cambios de estado (selección de opción, aparición de resultado).
- `transform` y `opacity` exclusivamente en las animaciones críticas, para
  mantenerlas en la capa de composición del navegador (GPU) y no forzar
  reflow/layout.
- `prefers-reduced-motion` respetado: si el usuario lo tiene activado, se
  desactivan las animaciones no esenciales.

## Justificación

- Cero dependencias, cero peso extra.
- `transform`/`opacity` son las propiedades más baratas de animar.
- Suficiente para: barra de tiempo, feedback de respuesta correcta/incorrecta,
  entrada de ranking, podio final.

## Consecuencias

- Positivas: cliente liviano y fluido incluso en equipos de gama baja.
- Negativas: animaciones complejas (partículas, trayectorias) requerirían
  más esfuerzo o una librería. No las necesitamos en v1.