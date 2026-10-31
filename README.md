# aulaquiz

Alternativa autoalojable y libre a herramientas de quiz en vivo (tipo Wayground/Quizizz)
pensada específicamente para el escenario **clase online con 140 alumnos conectados
simultáneamente por Zoom**.

## Principios de diseño

1. **El cliente es el recurso escaso.** Zoom ya consume ~1–1.5 GB de RAM en el alumno.
   Nuestro cliente debe ser casi invisible: vanilla JS, CSS nativo, sin frameworks.
2. **El servidor es la única fuente de verdad.** Temporizador, validez de respuestas,
   puntaje y ranking se deciden en el backend.
3. **Diseñado para la red imperfecta.** Reconexión con snapshot de estado y período
   de gracia. La conexión *se va* a caer; el sistema debe sobrevivir a eso.
4. **Simple por decisión, no por limitación.** Un binario Go, estado en memoria,
   sin microservicios, sin Redis, sin base de datos relacional.

## Stack

- **Backend:** Go + `github.com/coder/websocket`, binario único con assets embebidos (`embed`).
- **Frontend:** HTML + CSS + JavaScript vanilla. Sin build step.
- **Transporte:** WebSocket sobre el mismo host del servidor.

## Documentación

Toda la documentación vive en [`docs/`](./docs). Empezá por:

- [`docs/01-requerimientos/alcance.md`](./docs/01-requerimientos/alcance.md)
- [`docs/02-arquitectura/vision-general.md`](./docs/02-arquitectura/vision-general.md)
- [`docs/03-adr/`](./docs/03-adr) — decisiones y su justificación
- [`docs/07-varios/roadmap-mvp.md`](./docs/07-varios/roadmap-mvp.md)

## Estado

MVP en diseño. Ver roadmap.

## Licencia

MIT.