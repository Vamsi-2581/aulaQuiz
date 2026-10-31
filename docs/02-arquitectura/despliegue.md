# Despliegue

## Artefacto

Un binario Go estático con los assets embebidos (`//go:embed web/*`).

go build -trimpath -ldflags="-s -w" -o aulaquiz ./cmd/aulaquiz
text


Tamaño esperado: **8–15 MB**.

## Configuración

| Variable | Default | Descripción |
|---|---|---|
| `PORT` | `8080` | Puerto HTTP/WebSocket |
| `QUIZ_PATH` | `./quiz.json` | Ruta al quiz a servir en v1 |
| `ALLOWED_ORIGIN` | `*` | Origen permitido para WS (ajustar en prod) |

## Ejecución

./aulaquiz


Sirve en `http://0.0.0.0:8080`:
- `/` → landing
- `/teacher` → panel docente
- `/play` → cliente alumno
- `/ws` → WebSocket

## Infraestructura sugerida

- **Opción A (recomendada):** VPS mínimo (1 vCPU, 512 MB RAM). Suficiente
  para 200 conexiones. HTTPS vía Caddy o nginx como reverse proxy.
- **Opción B:** Raspberry Pi 4 en la red local de la facultad, accesible por
  el Wi-Fi del aula. Útil para el modo presencial (v2) y para pruebas de carga.

## HTTPS

Requerido si se accede desde internet con navegadores modernos. WebSocket
sobre `wss://`. Caddy resuelve certificados automáticamente con un `Caddyfile`
de 3 líneas.

## Sin estado persistente

No hay volúmenes, no hay backups, no hay migraciones. Reiniciar el binario
pierde la sala activa; es aceptable en v1.

