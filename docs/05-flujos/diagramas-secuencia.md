# Diagramas de secuencia

## Join y inicio de partida

    Docente                Servidor                 Alumno 1..200
       │                      │                          │
       │ teacher.join         │                          │
       ├─────────────────────►│                          │
       │◄── room.snapshot ────┤                          │
       │                      │◄──── student.join ───────┤
       │                      ├──── student.joined ─────►│
       │◄── room.snapshot ────┤  (broadcast a docente)   │
       │                      │                          │
       │ teacher.start        │                          │
       ├─────────────────────►│                          │
       │                      ├── question.show ────────►│ (todos)
       │◄── question.show ────┤                          │

## Respuesta y resultados

    Alumno                 Servidor                Todos
       │                      │                      │
       │ student.answer       │                      │
       ├─────────────────────►│                      │
       │◄── answer.ack ───────┤                      │
       │                      │  (cada 500 ms)       │
       │◄── leaderboard.update┤─────────────────────►│
       │                      │                      │
       │  (docente avanza)    │                      │
       │                      ├─ question.results ──►│
       │◄─ question.results ──┤                      │

## Reconexión

    Alumno (desconectado)       Servidor
       │                           │
       │ (se corta el WS)          │
       │                           ├─ marca LastSeen
       │                           ├─ mantiene sesión 60 s
       │                           │
       │ student.reconnect         │
       ├──────────────────────────►│
       │                           ├─ valida sessionToken
       │◄── room.snapshot ─────────┤
       │                           │