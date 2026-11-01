# Despliegue

Esta guía describe el despliegue de una instancia Linux de aulaQuiz detrás de
un proxy HTTPS. En el estado actual de `main`, el roadmap todavía marca como
pendientes el servidor y el piloto: no hay `go.mod`, binario ni `cmd/aulaquiz`
para compilar todavía. Por eso, los comandos de compilación, el servicio y la
configuración de abajo son el procedimiento previsto para cuando se integre la
Fase 1; no implican que ya exista un release desplegable.

La instancia v1 es de un solo docente y una sala activa. El servidor sirve el
cliente y el WebSocket desde el mismo host. Ver [alcance](./01-requerimientos/alcance.md),
[componentes](./02-arquitectura/vision-general.md) y
[ADR-0002](./03-adr/ADR-0002-transporte-websocket.md).

## Requisitos del host

- Linux con systemd y acceso a una red desde los navegadores de los participantes.
- Go en la versión que indique el módulo cuando el servidor esté implementado.
- Nginx (u otro proxy con soporte WebSocket) y un certificado TLS válido.
- Un archivo de quiz JSON válido. El contrato actual lee el archivo indicado por
  `QUIZ_PATH` al iniciar; la guía de [formato de quiz](./02-arquitectura/formato-quiz.md)
  describe su estructura.
- Un token aleatorio para `TEACHER_TOKEN`. Tratalo como una contraseña: no lo
  guardes en Git, en el archivo del quiz ni en el historial del shell.

## Compilar e instalar

Cuando el servidor esté disponible en `main`, compílalo desde la raíz del repo.
Los assets web se embeben en el binario, así que no hace falta copiar una carpeta
de frontend junto al ejecutable.

```sh
mkdir -p dist
go build -trimpath -o dist/aulaquiz ./cmd/aulaquiz
```

Copia el binario al host. En este ejemplo, el usuario del servicio es
`aulaquiz` y el ejecutable queda en `/opt/aulaquiz/bin`:

```sh
sudo useradd --system --home-dir /var/lib/aulaquiz --create-home \
  --shell /usr/sbin/nologin aulaquiz
sudo install -d -o root -g aulaquiz -m 0750 /opt/aulaquiz/bin
sudo install -o root -g aulaquiz -m 0750 dist/aulaquiz /opt/aulaquiz/bin/aulaquiz
sudo install -d -o root -g aulaquiz -m 0750 /etc/aulaquiz/quizzes
sudo install -o root -g aulaquiz -m 0640 ./quizzes/class.json \
  /etc/aulaquiz/quizzes/class.json
```

Ajusta `./quizzes/class.json` al archivo que quieras servir. El proceso necesita
permiso de lectura sobre el quiz y el archivo de entorno. No pongas datos
personales de alumnos en los quizzes.

## Configuración

El contrato de configuración documentado usa estas variables:

| Variable | Ejemplo | Uso |
| --- | --- | --- |
| `PORT` | `8080` | Puerto HTTP local del servidor, detrás del proxy. |
| `QUIZ_PATH` | `/etc/aulaquiz/quizzes/class.json` | Ruta absoluta al quiz JSON cargado al iniciar. |
| `TEACHER_TOKEN` | token generado aleatoriamente | Credencial estática del docente. |

No hay un valor predeterminado de `PORT` documentado. Define los tres valores
explícitamente. Para crear un archivo de entorno privado y generar el token sin
escribirlo literalmente en un comando del historial:

```sh
sudo install -d -o root -g aulaquiz -m 0750 /etc/aulaquiz
sudo install -o root -g aulaquiz -m 0640 /dev/null /etc/aulaquiz/aulaquiz.env
sudoedit /etc/aulaquiz/aulaquiz.env
```

Pon en el archivo:

```dotenv
PORT=8080
QUIZ_PATH=/etc/aulaquiz/quizzes/class.json
TEACHER_TOKEN=<salida de: openssl rand -hex 32>
```

Ejecuta `openssl rand -hex 32` en una terminal confiable y pega el resultado
directamente en el editor. No subas este archivo al repositorio ni compartas el
token con los alumnos.

## Servicio systemd

Guarda esto como `/etc/systemd/system/aulaquiz.service`:

```ini
[Unit]
Description=aulaQuiz
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=aulaquiz
Group=aulaquiz
WorkingDirectory=/var/lib/aulaquiz
EnvironmentFile=/etc/aulaquiz/aulaquiz.env
ExecStart=/opt/aulaquiz/bin/aulaquiz
Restart=on-failure
RestartSec=2
StateDirectory=aulaquiz
StateDirectoryMode=0750
NoNewPrivileges=true
PrivateTmp=true
ProtectHome=true
ProtectSystem=strict

[Install]
WantedBy=multi-user.target
```

Activa el servicio y revisa el arranque:

```sh
sudo systemctl daemon-reload
sudo systemctl enable --now aulaquiz
sudo systemctl status aulaquiz
sudo journalctl -u aulaquiz -n 100 --no-pager
```

Los logs van a stdout/stderr y systemd los recoge en el journal. Si el proceso
no arranca, revisa primero que el archivo indicado por `QUIZ_PATH` exista y sea
legible para el usuario `aulaquiz`, que el archivo de entorno tenga permisos
`0640`, y que el puerto no esté ocupado. Tras reemplazar el binario, ejecuta
`sudo systemctl restart aulaquiz`.

## Proxy inverso con Nginx

Termina TLS en el proxy y limita el acceso directo al puerto del servidor para
que los clientes entren por HTTPS. El ejemplo asume que Nginx y aulaQuiz corren
en el mismo host y que el servidor escucha en `127.0.0.1:8080`; adapta el
upstream a la dirección de escucha que implemente el servidor.

Dentro del bloque `http {}`, declara el mapa para el encabezado de actualización:

```nginx
map $http_upgrade $connection_upgrade {
    default upgrade;
    ''      close;
}
```

En el bloque `server {}` que ya configura el certificado TLS:

```nginx
location / {
    proxy_pass http://127.0.0.1:8080;
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection $connection_upgrade;
    proxy_buffering off;
    proxy_read_timeout 75s;
    proxy_send_timeout 75s;
}
```

El ping/pong del protocolo está previsto cada 20 segundos
([ADR-0002](./03-adr/ADR-0002-transporte-websocket.md)). Los timeouts del proxy
deben ser mayores que ese intervalo; el ejemplo de 75 segundos permite varios
pings perdidos antes de cerrar una conexión inactiva. Conserva HTTP y WebSocket
en el mismo host y valida el certificado antes de compartir el enlace con la
clase. Después de modificar Nginx, ejecuta `sudo nginx -t` y recarga el servicio.

## Datos y copias de seguridad

El estado de una sala vive en memoria: reiniciar aulaQuiz termina la partida
activa. La persistencia SQLite de estadísticas está especificada en
[ADR-0012](./03-adr/ADR-0012-persistencia-estadisticas-sqlite.md), que sigue
propuesto, y el roadmap la ubica después del piloto. Hasta que se implemente,
no habrá una base de datos `data/` que respaldar.

Cuando esa persistencia esté implementada, el archivo inicial previsto para v1
es `data/tenants/default.db`. Con el `WorkingDirectory` de la unidad anterior,
su ubicación será `/var/lib/aulaquiz/data/tenants/default.db`. Programa copias
de seguridad con permisos restringidos y verifica cada copia. Usa el backup en
línea de SQLite para incluir correctamente los cambios en WAL; no copies solo
el archivo `.db` mientras el servidor está escribiendo:

```sh
sudo install -d -o root -g root -m 0700 /var/backups/aulaquiz
sudo sqlite3 /var/lib/aulaquiz/data/tenants/default.db \
  '.backup /var/backups/aulaquiz/default.db'
sudo sqlite3 /var/backups/aulaquiz/default.db 'PRAGMA integrity_check;'
```

El resultado de `integrity_check` debe ser `ok`. Conserva varias copias según
la política de retención de tu institución, y prueba la restauración en una
instancia detenida antes de depender de ella. La base guarda estadísticas
agregadas, no identidades de alumnos. Respalda también los archivos de quiz por
separado; son necesarios para volver a iniciar la instancia con el mismo quiz.

## Rotar el token docente

La configuración se carga desde `EnvironmentFile` cuando systemd inicia el
proceso. El proyecto no documenta recarga en caliente de `TEACHER_TOKEN`, así
que la rotación requiere reiniciar el servicio:

1. Genera un token nuevo con `openssl rand -hex 32`.
2. Reemplaza `TEACHER_TOKEN` en `/etc/aulaquiz/aulaquiz.env` usando
   `sudoedit`; conserva propietario y modo `root:aulaquiz 0640`.
3. Reinicia con `sudo systemctl restart aulaquiz` y confirma con
   `sudo systemctl status aulaquiz`.
4. Actualiza la credencial del docente en el medio seguro donde la distribuyes.
   No la publiques en una URL, issue, chat de clase ni archivo versionado.

El reinicio termina cualquier sala que siga en memoria. Programa la rotación
fuera de una clase activa y avisa al docente por el canal operativo que ya use.
