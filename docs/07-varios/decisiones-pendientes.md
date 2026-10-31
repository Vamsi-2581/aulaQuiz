# Decisiones pendientes

Archivo vivo. Cada ítem se resuelve con un ADR, se mueve al doc correspondiente
y se borra de acá. Si un agente va a implementar algo en esta lista, **primero**
propone resolución y abre ADR.

## Abiertas

| # | Tema | Estado |
|---|---|---|
| 1 | Modo presencial (v2) | fuera de alcance v1 |
| 2 | Editor visual de quizzes (v2) | fuera de alcance v1 |
| 3 | Persistencia de resultados al docente (v2) | fuera de alcance v1 |
| 4 | Listas y tablas en Markdown (v2) | fuera de alcance v1 |
| 5 | Anidamiento en Markdown (v2) | fuera de alcance v1 |
| 6 | i18n (v2) | fuera de alcance v1 |
| 7 | Soporte de imágenes en preguntas (v2) | fuera de alcance v1 |

## Resueltas (referencia)

| Tema | Resolución |
|---|---|
| Respuestas de `student.join` / `teacher.create` | `student.joined` / `teacher.created` con snapshot + token (protocolo v2) |
| Formato del quiz | `docs/02-arquitectura/formato-quiz.md` |
| Tie-break de puntajes | Glosario, sección "Desempate" |
| Takeover de sesión | ADR-0011 |
| Markdown en preguntas y opciones | ADR-0010 |
| Límite de alumnos | `room_full` con 140 (RNF-01) |
| Docente desconectado | El timer no se pausa; `teacher.disconnected` / `teacher.reconnected` |
| Formato del nickname | protocolo, sección "Validación de nickname" |
| Quiz inválido al arrancar | `formato-quiz.md`, validación bloqueante |