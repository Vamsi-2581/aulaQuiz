# ADR-0003 — Cliente sin framework, vanilla JS + CSS

- **Estado:** aceptado

## Contexto

En clase online, Zoom consume **1–1.5 GB de RAM** y buena parte del CPU del
alumno. Cualquier peso adicional en el cliente compite directamente con Zoom
y degrada la experiencia. Además, los alumnos usan equipos heterogéneos,
muchos de gama baja.

## Decisión

Cliente escrito en **HTML + CSS + JavaScript vanilla**, sin build step, sin
frameworks, sin dependencias externas. Las animaciones se hacen con CSS
(`@keyframes`, `transition`) y la manipulación mínima de DOM.

## Justificación

- Bundle objetivo **< 150 KB comprimido**: alcanzable holgadamente.
- Sin paso de build: los archivos se sirven tal cual desde el binario.
- Sin CDNs externos: no hay requests a dominios de terceros, no hay latencia
  adicional ni riesgo de bloqueo.
- CSS nativo es suficiente para las animaciones que necesitamos (barra de
  tiempo, transición de opciones, podio).

## Consecuencias

- Positivas: control total del peso, cero dependencias, máxima compatibilidad.
- Negativas: más código manual para manipular DOM. Mitigación: helpers
  pequeños en `shared.js` (`el()`, `on()`, `render()`), sin abstracciones
  grandes.

## Alternativas consideradas

- **Preact:** ~4 KB gzip, buena opción, pero requiere build step y agrega
  una capa de abstracción que no se justifica para 3 pantallas.
- **Svelte:** excelente output, pero agrega toolchain.
- **React:** descartado por peso y runtime.

## Nota

Si en algún momento el código vanilla se vuelve inmanejable, se evalúa Preact
con un ADR de supersesión.