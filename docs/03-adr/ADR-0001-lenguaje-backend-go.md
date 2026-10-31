# ADR-0001 — Backend en Go

- **Estado:** aceptado
- **Fecha:** 2026-10-31

## Contexto

Necesitamos un backend que sostenga 200 WebSockets concurrentes en una única
instancia, con un binario simple de desplegar y fácil de mantener por un equipo
docente pequeño. Se evaluaron Go y Rust.

## Decisión

Usar **Go** con `github.com/coder/websocket`.

## Justificación

- A la escala de 200 conexiones, **ambos lenguajes sobran**. La diferencia de
  memoria por conexión (~15–30 KB) y de latencia (~6 ms P99) no se materializa
  en la experiencia del alumno.
- Go ofrece concurrencia explícita y simple (goroutines + channels) que se
  traduce en menos tiempo de desarrollo y menos superficie de bugs para un
  equipo chico.
- Un binario Go único se despliega sin toolchain ni runtime adicional.
- El cuello de botella real está en el **cliente** (Zoom consumiendo RAM) y en
  la **red del alumno**, no en el servidor.

## Consecuencias

- Positivas: desarrollo rápido, despliegue trivial, comunidad grande de
  ejemplos de servidores WebSocket.
- Negativas: GC puede introducir picos de latencia bajo cargas extremas
  (>10k conexiones). Aceptable a nuestra escala; si en el futuro se necesita
  más, se evalúa migrar o shardear.

## Alternativas consideradas

- **Rust (Tokio + Axum):** mejor uso de memoria y latencia, pero mayor tiempo
  de desarrollo y complejidad innecesaria a esta escala.
- **Node.js:** viable, pero el modelo single-thread y el peso del runtime no
  aportan ventaja frente a Go en este escenario.