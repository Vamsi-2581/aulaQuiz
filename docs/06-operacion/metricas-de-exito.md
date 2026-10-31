# Métricas de éxito

## Del sistema (medibles en pruebas)

| Métrica | Objetivo | Cómo se mide |
|---|---|---|
| Conexiones concurrentes soportadas | 140 + docente | `k6` con 141 WebSockets |
| Latencia p95 answer → ack | < 200 ms | Instrumentación de timestamps en k6 |
| Memoria del servidor con 141 clientes | < 100 MB RSS | `ps` / métricas del proceso |
| CPU del servidor con 141 clientes | < 25 % de 1 vCPU | `top` durante prueba |
| Bundle del cliente (gzip) | < 150 KB | `du` sobre assets comprimidos |
| Requests a dominios externos desde el cliente | 0 | DevTools Network |
| RAM del cliente con Zoom abierto | +50 MB máx | DevTools Memory |

## De la experiencia (a validar en clase real)

| Métrica | Objetivo | Cómo se mide |
|---|---|---|
| Tiempo de join (código → dentro) | < 15 s | Cronómetro en prueba con alumnos |
| Alumnos que logran responder pregunta 1 | > 95 % | Log del servidor |
| Alumnos que completan la partida sin re-join manual | > 90 % | Log del servidor |
| Percepción de fluidez del docente | "igual o mejor que Wayground" | Encuesta breve post-clase |

## Criterio de "superador"

Se considera que el MVP supera a Wayground si, en una clase real de 140
alumnos por Zoom:
1. Ningún alumno reporta "no me cargó" o "se trabó" de forma bloqueante.
2. La latencia percibida es indistinguible de la de un quiz local.
3. El docente puede narrar la clase sin que el panel se congele.