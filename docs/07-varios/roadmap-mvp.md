# Roadmap MVP

## Fase 0 — Documentación (este bloque)

- [x] Requerimientos funcionales y no funcionales
- [x] Alcance y fuera de alcance
- [x] Visión de arquitectura y componentes
- [x] Protocolo WebSocket
- [x] Modelo de datos
- [x] ADRs 0001–0009
- [x] Features Gherkin
- [x] Flujos y diagramas
- [x] Plan de pruebas de carga

## Fase 1 — Esqueleto del servidor

- [ ] `cmd/aulaquiz/main.go` con router y `/ws`
- [ ] `internal/protocol` con structs de mensajes (incluye `Node` AST de ADR-0010)
- [ ] `internal/markdown`: parser + validador + tests (ADR-0010)
- [ ] `internal/quiz`: loader + validación bloqueante de `formato-quiz.md`
- [ ] `internal/hub` con crear/get/delete de salas
- [ ] `internal/room` con estados `lobby → question_open → question_closed → finished`
- [ ] `internal/client` con lectura/escritura concurrente, ping/pong y takeover (ADR-0011)
- [ ] `internal/domain` con `StatsRepository` (interfaz)
- [ ] `internal/storage/sqlite`: apertura, migraciones embebidas, `user_version`
- [ ] `internal/storage/sqlite`: implementación de `StatsRepository`
      (escritura al cerrar sala, lectura para reporte)
- [ ] `internal/auth`: interfaz `Authenticator`, implementación `StaticToken`
      (Fase 1)
- [ ] Tests unitarios de `domain/scoring`, `domain/ranking`, `markdown`,
      `storage/sqlite` (con SQLite en memoria)

## Fase 2 — Cliente mínimo

- [ ] `web/render-ast.js` (ADR-0010)
- [ ] `web/play.html` + `web/play.js`: join, lobby, responder, feedback
- [ ] `web/teacher.html` + `web/teacher.js`: crear sala, ver participantes,
      iniciar, avanzar, ver resultados
- [ ] Animaciones CSS: barra de tiempo, selección, feedback
- [ ] Reconexión con backoff y `room.snapshot`
- [ ] Manejo de `session.takeover` (detener reintentos + aviso)

## Fase 3 — Avatares y podio

- [ ] `domain/avatar` con derivación determinística
- [ ] Render de avatar en cliente (CSS + inicial)
- [ ] Animación de podio al finalizar

## Fase 4 — Pruebas

- [ ] Features Gherkin como tests de integración (usando `godog` o equivalente)
- [ ] Script k6 para los 5 escenarios de carga
- [ ] Prueba con red degradada

## Fase 5 — Piloto en clase real

- [ ] Despliegue en VPS
- [ ] Clase con 200 alumnos por Zoom
- [ ] Recolección de métricas y feedback
- [ ] Ajustes post-piloto

## Fase 6 — Publicación

- [ ] Licencia MIT
- [ ] README final con instrucciones de uso
- [ ] Anuncio a la comunidad docente de la facultad

## Fase 7 (post-MVP) — Modo presencial

- [ ] Adaptar a red local (Raspberry Pi o servidor en el aula)
- [ ] Test de carga en Wi-Fi de aula
- [ ] Consideraciones de NAT y contención de espectro

## Fase 1.5 — Estadísticas y reportes (post-piloto)

- [ ] Comando `aulaquiz report --quiz <id> --last <n>` que lee SQLite y
      muestra promedios por pregunta
- [ ] Endpoint `GET /teacher/report/:sessionId` para el panel docente
- [ ] Multi-quiz: `QUIZ_DIR` en vez de `QUIZ_PATH`, selector en el panel
- [ ] Backup documentado (`cp data/tenants/default.db backup/`)

## Fase 2 — Multi-tenant

Ver `docs/02-arquitectura/modelo-tenant.md` para la estrategia completa.

- [ ] OAuth para docentes (recomendado: `goth`)
- [ ] Un archivo SQLite por tenant (`data/tenants/<tenant_id>.db`)
- [ ] Selector de quiz filtrado por tenant
- [ ] Panel de reportes filtrado por tenant
- [ ] Migración de datos existentes (`default` → tenant real)