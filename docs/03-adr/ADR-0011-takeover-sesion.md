# ADR-0011 — Takeover de sesión y múltiples conexiones

- **Estado:** aceptado
- **Fecha:** 2026-10-31

## Contexto

Un alumno puede abrir dos pestañas, o recargar la página, o perder la conexión
y reconectar. Sin una regla explícita, el servidor puede terminar con dos
conexiones activas para el mismo `sessionToken`, lo que produce respuestas
duplicadas, puntajes inconsistentes y confusión.

## Decisión

**Una sesión, una conexión activa**. Una nueva conexión con un token válido
**toma el control** (takeover):

1. El servidor detecta que ya hay una conexión activa para ese token.
2. Cierra la conexión vieja con WebSocket close code **4000** y razón
   `session.takeover`.
3. Envía a la conexión vieja un mensaje `session.takeover` antes del cierre
   (best-effort; si el cliente ya está muerto, el cierre con código 4000 es
   suficiente).
4. La conexión nueva queda como la activa y recibe `room.snapshot`.
5. El cliente que recibe `session.takeover` **deja de reconectar** y muestra
   un aviso: "Tu sesión se abrió en otra pestaña o dispositivo".

Aplica igual para alumnos y docentes.

## Justificación

- Determinista y simple de razonar.
- Elimina el caso "dos respuestas por pregunta" sin lógica de deduplicación.
- La recarga de pestaña funciona sin fricción: el token en `localStorage`
  reconecta y toma el control; el usuario ni se enteró.
- Un segundo dispositivo accidental (alumno abre en el celular) se resuelve
  solo: la primera conexión se cierra con aviso.

## Consecuencias

- Positivas: un solo estado por sesión; sin duplicados; recarga transparente.
- Negativas: si el usuario tiene dos pestañas **a propósito**, la primera
  se cierra con aviso. Aceptable y predecible.

## Alternativas consideradas

- **Rechazar la segunda conexión** (`session_already_active`): deja al usuario
  trabado si la primera pestaña está colgada (half-open TCP). Peor UX.
- **Permitir múltiples conexiones por sesión**: requiere deduplicación de
  respuestas y complica el modelo. Descartado.