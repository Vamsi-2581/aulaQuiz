# Requerimientos no funcionales

## RNF-01 — Concurrencia

Soportar **200 alumnos + 1 docente** en una sala con WebSockets activos, sobre
una única instancia del servidor.

## RNF-02 — Peso del cliente

- El bundle servido al alumno (HTML + CSS + JS + assets) debe ser **< 150 KB**
  comprimido (gzip/brotli).
- El cliente no debe realizar **ningún request a dominios externos**.
- El cliente no debe cargar frameworks (React, Vue, Angular, Svelte runtime, jQuery).

## RNF-03 — Consumo del cliente

Con Zoom activo en la misma máquina, el quiz no debe agregar más de:
- **50 MB** de memoria al proceso del navegador.
- **5 %** de CPU sostenido en un equipo de gama baja (referencia: 4 GB RAM,
  CPU de 2 núcleos de 2018 o similar).

## RNF-04 — Latencia percibida

El envío de una respuesta y la recepción del ACK debe completarse en
**< 200 ms en p95** bajo condiciones de red normales.

## RNF-05 — Compatibilidad

- Chrome / Edge ≥ 110, Firefox ≥ 110, Safari ≥ 16 (desktop prioritario).
- Sin APIs experimentales. WebSocket nativo, `fetch`, `localStorage`, CSS
  `@keyframes` y `transition` estándar.
- Sin `WebTransport`, sin `SharedArrayBuffer`, sin service workers en v1.

## RNF-06 — Tolerancia a fallos de red

- Reconexión automática con backoff exponencial (mín. 500 ms, máx. 5 s).
- Período de gracia de sesión: 60 s.
- El estado del cliente debe poder reconstruirse desde un `room.snapshot`.

## RNF-07 — Simplicidad operativa

- Un único binario Go, sin dependencias externas en runtime (sin Redis,
  sin DB, sin message broker).
- Despliegue por copia del binario + variable de entorno de puerto.
- Logs a stdout en formato texto plano.

## RNF-08 — Mantenibilidad

- Cobertura de tests en el servidor ≥ 70 % en paquetes de dominio (sala, puntaje).
- Cada decisión arquitectónica relevante debe tener su ADR.
- Cada comportamiento observable debe tener al menos una feature Gherkin.

## RNF-09 — Ética y privacidad

- No se recolecta ningún dato personal más allá del nickname y (opcionalmente)
  el email institucional.
- No se persiste nada en disco ni en base de datos.
- No se envía telemetría a terceros.

## RNF-10 — Render de Markdown

- El cliente no incluye parser de Markdown. El AST se renderiza con
  `document.createTextNode` y `document.createElement`.
- `web/render-ast.js` no debe superar los **3 KB gzipped**.
- RNF-02 (150 KB totales) se mantiene como presupuesto global.