# ADR-0012 — Persistencia de estadísticas en SQLite desde Fase 1

- **Estado:** propuesto (a confirmar al cerrar el piloto)
- **Fecha:** 2026-11-01
- **Relacionado:** ADR-0004 (estado en memoria), ADR-0005 (registro efímero)

## Contexto

ADR-0004 establece que el estado de una sala vive en memoria del proceso.
Eso sigue siendo correcto para el **hot path**: respuestas, ranking, timer.

Pero el proyecto necesita, desde Fase 1, **persistir estadísticas de cada
partida** para que el docente pueda ver, después de la clase:
- Cuántos alumnos participaron.
- Porcentaje de acierto por pregunta.
- Distribución de respuestas por opción.
- Tiempo promedio de respuesta por pregunta.

Esto es una **herramienta pedagógica**, no un sistema de marketing ni un
registro de personas. No se persiste nada que identifique a un alumno.

La pregunta es: ¿dónde vive esa persistencia, y cómo se prepara el esquema
para no reescribir cuando el proyecto pase a multi-tenant (Fase 2)?

## Decisión

1. **Persistir estadísticas agregadas en SQLite embebido**, desde Fase 1.
2. **El hot path nunca toca SQLite.** El estado de sala sigue en memoria
   (ADR-0004 vigente). SQLite se toca solo en bordes: al cerrar una sala
   (escritura) y al generar reportes (lectura).
3. **Incluir `tenant_id` en el esquema desde Fase 1**, con valor `"default"`.
   En Fase 2 el valor vendrá del docente autenticado. Las queries no cambian.
4. **No persistir datos de alumnos.** Ni `student_id`, ni `nickname`, ni
   `email`, ni `ip`. Solo agregados por pregunta.
5. **Driver:** `modernc.org/sqlite` (pure Go, sin CGo). Prioriza portabilidad
   de cross-compilación sobre performance bruta; a esta escala, la diferencia
   es irrelevante.
6. **Modo WAL** habilitado: múltiples lectores concurrentes, un solo escritor
   serializado. Coincide exactamente con el patrón de uso (escrituras en el
   cierre de sala, lecturas para reportes).
7. **Migraciones embebidas** con `embed.FS` y un contador de versión en
   `PRAGMA user_version`. Sin dependencias externas de migración.

## Esquema mínimo

```sql
CREATE TABLE tenants (
    id          TEXT PRIMARY KEY,
    name        TEXT NOT NULL,
    created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE quizzes (
    id          TEXT NOT NULL,
    tenant_id   TEXT NOT NULL REFERENCES tenants(id),
    title       TEXT NOT NULL,
    version     INTEGER NOT NULL,
    file_hash   TEXT NOT NULL,
    PRIMARY KEY (tenant_id, id)
);

CREATE TABLE game_sessions (
    id            TEXT PRIMARY KEY,
    tenant_id     TEXT NOT NULL REFERENCES tenants(id),
    quiz_id       TEXT NOT NULL,
    room_code     TEXT NOT NULL,
    started_at    DATETIME NOT NULL,
    finished_at   DATETIME NOT NULL,
    participants  INTEGER NOT NULL,
    UNIQUE (tenant_id, room_code, finished_at)
);

CREATE TABLE question_stats (
    session_id       TEXT NOT NULL REFERENCES game_sessions(id) ON DELETE CASCADE,
    question_index   INTEGER NOT NULL,
    question_id      TEXT NOT NULL,
    correct_count    INTEGER NOT NULL,
    total_answers    INTEGER NOT NULL,
    avg_elapsed_ms   INTEGER NOT NULL,
    option_counts    TEXT NOT NULL,
    PRIMARY KEY (session_id, question_index)
);
```

## Flujo

1. Al arrancar: se abren conexiones a `data/tenants/<tenant_id>.db` (en Fase 1,
   `data/tenants/default.db`), se aplican migraciones, se registra el tenant.
2. Durante el juego: **nada** toca SQLite.
3. Al cerrar la sala (`teacher.close` o fin natural): se escribe, en una sola
   transacción, una fila en `game_sessions` + N filas en `question_stats`.
   Best-effort: si falla, se loguea y la sala se cierra igual.
4. Reportes: se leen desde el repo de estadísticas, filtrando por `tenant_id`
   del contexto y `quiz_id`.

## Justificación

- **Hot path intacto:** ADR-0004 sigue vigente para el estado de sala.
- **Herramienta pedagógica real:** el docente obtiene datos accionables
  (¿qué pregunta falló más?) sin construir un sistema de analítica.
- **Sin datos de alumnos:** cumple ADR-0005 y evita cualquier obligación de
  privacidad adicional.
- **Multi-tenant-ready:** `tenant_id` está desde el inicio. En Fase 2 solo
  cambia el valor que baja por `context.Context`.
- **Aislamiento por archivo:** en Fase 2 se puede migrar a un `.db` por
  tenant sin cambiar el repositorio, solo la apertura de conexión.
- **SQLite es auto-alojable:** un archivo, sin servicio, backup = `cp`.
  Coherente con el objetivo del proyecto.

## Consecuencias

- Positivas:
  - Estadísticas sin infraestructura extra.
  - Esquema preparado para multi-tenant sin reescritura.
  - Sin obligaciones de privacidad sobre alumnos.
- Negativas:
  - El binario crece ~20–25 MB por `modernc.org/sqlite`.
  - Aparece `data/` en disco: hay que decidir ubicación, permisos y backup.
  - Un archivo `.db` por tenant requiere gestión de paths en Fase 2.

## Alternativas consideradas

- **Solo archivos JSON en `results/`:** funciona para L1/L2, pero para
  agregaciones (L3: promedios por pregunta a lo largo de varias partidas)
  obliga a parsear N archivos y agregar en código. SQLite resuelve eso con
  SQL y transacciones.
- **Postgres / MySQL:** rompe “auto-alojable”, agrega servicio, backups,
  usuarios. Sobredimensionado a esta escala.
- **SQLite desde Fase 0 (antes del piloto):** innecesario. El piloto valida
  latencia y red; la persistencia es un borde. Meterla antes retrasa el piloto
  sin beneficio.

## Criterio de aceptación

Este ADR pasa a `aceptado` cuando:
1. El piloto se haya hecho con éxito (140 alumnos, latencia aceptable).
2. Al menos un docente haya usado el reporte de estadísticas post-partida.
3. Se haya validado que la escritura al cerrar sala no agrega latencia
   perceptible al cliente.

Mientras tanto, queda `propuesto`. La Fase 1 puede implementar el esquema y
las migraciones, pero el cierre de sala escribe best-effort y no bloquea.