# ADR-0004 — Estado de sala en memoria, sin Redis ni DB

- **Estado:** aceptado

## Contexto

Necesitamos almacenar el estado de una partida (alumnos, respuestas, puntajes)
con acceso de baja latencia desde el proceso que sirve los WebSockets.

## Decisión

Estado **en memoria del proceso**, protegido por `sync.RWMutex` dentro de cada
`Room`. Sin Redis, sin base de datos.

## Justificación

- A 200 alumnos, el volumen de estado es trivial (decenas de KB).
- El acceso en memoria es más rápido que cualquier almacenamiento externo.
- Elimina dependencias de infraestructura, reduce puntos de fallo y simplifica
  el despliegue a "copiar un binario y ejecutarlo".
- La reconexión se resuelve con el `sessionToken` guardado en el mapa de
  estudiantes de la sala, no requiere persistencia externa.

## Consecuencias

- Positivas: despliegue trivial, latencia mínima, cero configuración.
- Negativas: reiniciar el servidor pierde la partida en curso. Aceptable en v1
  (una clase en vivo con reinicio es un caso raro y recuperable: se rearma
  la sala).
- Negativas: no escala horizontalmente sin cambios. Fuera de alcance en v1
  (una sala activa por servidor).

## Alternativas consideradas

- **Redis:** agrega latencia, un servicio que mantener y un punto de fallo.
  No se justifica para una sola instancia.
- **SQLite:** persistencia innecesaria; además introduce I/O y esquema que
  queremos evitar.