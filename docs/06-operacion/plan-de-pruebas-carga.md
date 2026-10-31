# Plan de pruebas de carga

## Herramienta

`k6` (script en `test/load/`), con el módulo `k6/ws`.

## Escenario 1 — Join masivo

- 140 clientes WebSocket se conectan en una ventana de 10 segundos.
- Cada uno envía `student.join` con nickname único.
- **Criterio de éxito:** 100 % de joins exitosos, p95 de `student.joined` < 500 ms.

## Escenario 2 — Pregunta con respuestas en ráfaga

- 140 clientes conectados, docente emite `question.show`.
- Todos los alumnos responden en una ventana de 2 segundos.
- **Criterio de éxito:** 100 % de `answer.ack` recibidos, p95 < 200 ms,
  servidor por debajo de 100 MB RSS y 25 % CPU.

## Escenario 3 — Reconexión masiva

- 50 clientes se desconectan abruptamente.
- Reconectan entre 10 y 40 segundos después.
- **Criterio de éxito:** 100 % reciben `room.snapshot` con su puntaje intacto.

## Escenario 4 — Partida completa

- 10 preguntas, 140 alumnos respondiendo cada una.
- **Criterio de éxito:** sin desconexiones no intencionales, ranking estable,
  podio correcto al final.

## Escenario 5 — Red degradada (simulación)

- Añadir latencia de 100 ms y 1 % de pérdida de paquetes con `tc` o similar.
- **Criterio de éxito:** reconexión automática funciona, no se pierde puntaje.

## Registro de resultados

Cada corrida se documenta en `test/load/results/<fecha>.md` con:
- Hardware del servidor.
- Versión del binario.
- Configuración de k6.
- Métricas observadas.
- Conclusiones.