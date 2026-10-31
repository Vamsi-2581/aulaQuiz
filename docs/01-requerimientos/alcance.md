# Alcance

## En alcance (v1)

- Clase **online** (alumnos y docente conectados por videoconferencia, cada uno en su equipo).
- Un docente, una sala activa por vez, hasta **140 alumnos**.
- Quiz de preguntas multiple-choice con una única respuesta correcta.
- Registro efímero del alumno (nickname obligatorio, email institucional opcional).
- Avatar generado localmente a partir del nickname.
- Puntaje con bonus por velocidad, ranking en vivo y podio de ganadores al final.
- Reconexión tolerante a cortes de red.
- Despliegue en un único binario.

## Fuera de alcance (v1)

- Modo presencial / aula física (queda como segunda alternativa para v2).
- Anti-cheating de cualquier tipo (no se detecta cambio de pestaña, ni se bloquea
  copiar/pegar, ni se valida identidad).
- Autenticación persistente, cuentas de usuario, login.
- Historial de partidas, analytics, reportes exportables.
- Editor visual de quizzes (los quizzes se cargan desde un archivo JSON).
- Preguntas de respuesta abierta, imágenes en preguntas, audio, video.
- Múltiples docentes en una sala, salas concurrentes en el mismo servidor.
- Aplicación móvil nativa.
- Internacionalización (solo español rioplatense en v1).

## Supuestos

- El docente comparte pantalla por Zoom durante la partida.
- Cada alumno tiene un navegador moderno (Chrome/Edge/Firefox/Safari de los
  últimos 3 años) en desktop o notebook. **No se optimiza para móvil en v1**,
  aunque debe funcionar.
- El servidor se despliega en un VPS accesible por internet o en la red local
  de la facultad.