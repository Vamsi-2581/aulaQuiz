# Visión general de la arquitectura

## Diagrama de contexto

    ┌────────────┐         Zoom (voz + video + pantalla)        ┌────────────┐
    │  Docente   │◄────────────────────────────────────────────►│  Alumnos   │
    └─────┬──────┘                                              └─────┬──────┘
          │                                                           │
          │  WebSocket (panel docente)                WebSocket (quiz)│
          │                                                           │
          └───────────────────┬───────────────────────────────────────┘
                              │
                     ┌────────▼────────┐
                     │  aulaquiz (Go)  │
                     │  ─ Sala en RAM  │
                     │  ─ Assets embed │
                     └─────────────────┘

Zoom y aulaquiz son **canales independientes**. Zoom transporta voz, video y
pantalla compartida; aulaquiz transporta el estado del juego. El único punto
de contacto es el alumno mirando la pantalla compartida del docente.

## Componentes internos del servidor

    ┌──────────────────────────────────────────────────────────┐
    │                        aulaquiz                          │
    │                                                          │
    │  HTTP router ─┬─► /            (assets embebidos)        │
    │               ├─► /teacher     (panel docente)           │
    │               ├─► /play        (cliente alumno)          │
    │               └─► /ws          (WebSocket)               │
    │                                                          │
    │  Hub (registro de salas)                                 │
    │   └─ Room (una por código)                               │
    │       ├─ mutex + estado de la partida                    │
    │       ├─ mapa de clientes (docente + alumnos)            │
    │       ├─ canal de broadcast                              │
    │       └─ goroutine de tick (ranking agregado)            │
    │                                                          │
    │  Domain (lógica pura, testeable)                         │
    │       ├─ Scoring                                         │
    │       ├─ Ranking                                         │
    │       └─ Avatar (derivación determinística de seed)      │
    └──────────────────────────────────────────────────────────┘

## Principios

1. **Estado autoritativo en el servidor.** El cliente es un renderizador.
2. **Un solo proceso.** No hay microservicios ni servicios externos.
3. **Broadcast agregado.** El servidor no retransmite mensajes individuales;
   agrega y emite a intervalos o al cierre de eventos (ADR-0007).
4. **Snapshots idempotentes.** Cualquier cliente que se reconecta recibe un
   `room.snapshot` con todo lo necesario para renderizar el estado actual.
5. **El dominio no sabe de WebSocket.** `domain/` es lógica pura sin imports
   de red ni de HTTP, testeable con `go test` sin levantar servidor.