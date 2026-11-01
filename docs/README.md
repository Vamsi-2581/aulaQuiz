# Documentación de aulaquiz

Índice de la documentación. Todo lo relevante vive acá.

## 01 — Requerimientos

- [Alcance](./01-requerimientos/alcance.md)
- [Requerimientos funcionales](./01-requerimientos/requerimientos-funcionales.md)
- [Requerimientos no funcionales](./01-requerimientos/requerimientos-no-funcionales.md)

## 02 — Arquitectura

- [Visión general](./02-arquitectura/vision-general.md)
- [Componentes](./02-arquitectura/componentes.md)
- [Protocolo WebSocket](./02-arquitectura/protocolo-websocket.md)
- [Modelo de datos](./02-arquitectura/modelo-de-datos.md)
- [Despliegue](./02-arquitectura/despliegue.md)
- [Formato del quiz](./02-arquitectura/formato-quiz.md)
- [Modelo de tenant y aislamiento](./02-arquitectura/modelo-tenant.md)

## 03 — ADRs (Architecture Decision Records)

- [ADR-0001 — Backend en Go](./03-adr/ADR-0001-lenguaje-backend-go.md)
- [ADR-0002 — WebSocket](./03-adr/ADR-0002-transporte-websocket.md)
- [ADR-0003 — Cliente sin framework](./03-adr/ADR-0003-cliente-sin-framework.md)
- [ADR-0004 — Estado en memoria](./03-adr/ADR-0004-estado-en-memoria.md)
- [ADR-0005 — Registro efímero](./03-adr/ADR-0005-registro-efimero.md)
- [ADR-0006 — Temporizador autoritativo](./03-adr/ADR-0006-temporizador-autoritativo.md)
- [ADR-0007 — Broadcast agregado](./03-adr/ADR-0007-broadcast-agregado.md)
- [ADR-0008 — Animaciones CSS](./03-adr/ADR-0008-animaciones-css-nativas.md)
- [ADR-0009 — Avatares generados](./03-adr/ADR-0009-avatares-generados-localmente.md)
- [ADR-0010 — Soporte de Markdown](./03-adr/ADR-0010-soporte-markdown.md)
- [ADR-0011 — Takeover de sesión](./03-adr/ADR-0011-takeover-sesion.md)
- [ADR-0012 — Persistencia de estadísticas en SQLite](./03-adr/ADR-0012-persistencia-estadisticas-sqlite.md)

## 04 — Gherkin (comportamiento observable)

- [Sala y registro](./04-gherkin/01-sala-y-registro.feature)
- [Partida en vivo](./04-gherkin/02-partida-en-vivo.feature)
- [Reconexión](./04-gherkin/03-reconexion.feature)
- [Puntaje y ganadores](./04-gherkin/04-puntaje-y-ganadores.feature)
- [Avatares](./04-gherkin/05-avatares.feature)
- [Markdown](./04-gherkin/06-markdown.feature)

## 05 — Flujos

- [Flujo del docente](./05-flujos/flujo-docente.md)
- [Flujo del alumno](./05-flujos/flujo-alumno.md)
- [Diagramas de secuencia](./05-flujos/diagramas-secuencia.md)

## 06 — Operación

- [Métricas de éxito](./06-operacion/metricas-de-exito.md)
- [Plan de pruebas de carga](./06-operacion/plan-de-pruebas-carga.md)

## 07 — Varios

- [Glosario](./07-varios/glosario.md)
- [Roadmap MVP](./07-varios/roadmap-mvp.md)
- [Decisiones pendientes](./07-varios/decisiones-pendientes.md)

## 08 — Colaboración

- [Tu primer PR](./08-colaboracion/primer-pr.md)
- [Revisión de PRs](./08-colaboracion/revision-de-prs.md)

## Documentos raíz

- [AGENTS.md](../AGENTS.md) — restricciones duras para agentes y humanos
- [CONTRIBUTING.md](../CONTRIBUTING.md) — guía de contribución
- [CODE_OF_CONDUCT.md](../CODE_OF_CONDUCT.md)
- [SECURITY.md](../SECURITY.md)