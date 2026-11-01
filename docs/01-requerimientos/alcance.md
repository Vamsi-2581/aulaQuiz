# Alcance

## En alcance (v1)

- Clase **online** (alumnos y docente conectados por videoconferencia, cada uno en su equipo).
- **Single-tenant**: una instancia, un docente activo por vez, hasta **200 alumnos**.
  La arquitectura es multi-tenant-ready (ver `modelo-tenant.md`), pero la
  operación en v1 es single-tenant.
- Quiz de preguntas multiple-choice con una única respuesta correcta.
- Quizzes cargados desde archivos JSON validados al arrancar (`formato-quiz.md`).
- Registro efímero del alumno (nickname obligatorio, email institucional opcional).
- Avatar generado localmente a partir del nickname.
- Puntaje con bonus por velocidad, ranking en vivo y podio de ganadores al final.
- Reconexión tolerante a cortes de red y takeover de sesión entre pestañas.
- **Persistencia de estadísticas agregadas** de cada partida en SQLite
  (ADR-0012, propuesto): participantes, aciertos por pregunta, distribución
  de respuestas, tiempo promedio. **Sin datos de alumnos.**
- Despliegue en un único binario.

## Fuera de alcance (v1)

- Modo presencial / aula física (queda como segunda alternativa para v2).
- **Multi-tenant en operación** (múltiples docentes simultáneos en una misma
  instancia, cada uno con sus quizzes y estadísticas). El esquema lo soporta
  desde Fase 1, pero la operación es single-tenant.
- **Cuentas de alumno persistentes** (ADR-0005: registro efímero).
- Anti-cheating de cualquier tipo (no se detecta cambio de pestaña, ni se
  bloquea copiar/pegar, ni se valida identidad).
- Historial de partidas consultable desde el cliente (los resultados viven en
  SQLite, pero el acceso a ellos en v1 es solo desde el reporte post-partida
  del docente; un visor histórico queda para v2).
- Editor visual de quizzes (los quizzes se cargan desde un archivo JSON).
- Preguntas de respuesta abierta, imágenes en preguntas, audio, video.
- Aplicación móvil nativa.
- Internacionalización (solo español rioplatense en v1).
- Modelo freemium o cualquier forma de monetización (v2+, no ahora).

## Modelo de operación v1

`aulaQuiz` en v1 es **single-tenant con persistencia de estadísticas**. Eso
significa:

- Un docente, una sala activa, un quiz en curso.
- Los quizzes se cargan desde `quizzes/*.json` al arrancar.
- Las estadísticas de cada partida cerrada se persisten en SQLite
  (`data/tenants/default.db`).
- No hay cuentas de alumno.
- No hay cuentas de docente en v1 (ver `modelo-tenant.md` para la estrategia
  de autenticación).

La arquitectura está diseñada para pasar a multi-tenant en Fase 2 sin
reescritura: `tenant_id` existe en el esquema desde Fase 1, el aislamiento de
datos se hace por archivo SQLite por tenant, y la autenticación docente se
resuelve por una interfaz `Authenticator` que en Fase 1 es un token estático.

## Supuestos

- El docente comparte pantalla por Zoom durante la partida.
- Cada alumno tiene un navegador moderno (Chrome/Edge/Firefox/Safari de los
  últimos 3 años) en desktop o notebook. **No se optimiza para móvil en v1**,
  aunque debe funcionar.
- El servidor se despliega en un VPS accesible por internet o en la red local
  de la facultad.
