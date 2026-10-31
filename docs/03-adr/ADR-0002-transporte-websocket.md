# ADR-0002 — Transporte en tiempo real: WebSocket

- **Estado:** aceptado

## Contexto

Necesitamos comunicación bidireccional de baja latencia entre docente, alumnos
y servidor, con mensajería ordenada y compatible con navegadores de escritorio
modernos.

## Decisión

**WebSocket** sobre el mismo host del servidor, usando `github.com/coder/websocket`.

## Justificación

- Soporte universal en navegadores modernos, sin polyfills.
- Modelo simple de mensajes JSON.
- Bajo overhead frente a long-polling o SSE (SSE no permite cliente → servidor).
- WebRTC data channels ofrecerían menor latencia pero introducen complejidad
  desproporcionada: señalización ICE, STUN/TURN, negociación SDP, y una
  superficie de bugs enorme para un equipo chico.

## Consecuencias

- Positivas: simplicidad, compatibilidad, debuggable con DevTools.
- Negativas: si el proxy inverso no está bien configurado, los timeouts
  pueden cortar la conexión. Mitigación: ping/pong cada 20 s documentado en
  el protocolo.

## Alternativas consideradas

- **SSE + HTTP POST:** requiere dos canales, más complejo que WS.
- **WebRTC data channels:** sobredimensionado, sin beneficio claro a 200
  conexiones contra un servidor único.
- **Long polling:** alto overhead, latencia variable, peor experiencia.