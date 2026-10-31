# Flujo del docente

## Pre-clase

1. Levanta el servidor (o accede al desplegado).
2. Abre `/teacher`, hace click en "Crear sala".
3. Obtiene código (ej. `AB12`) y token (se guarda en `localStorage` del panel).
4. Comparte el código por el chat de Zoom y comparte pantalla del panel.

## Durante la partida

1. Espera en el lobby a que se conecten los alumnos (ve el contador en vivo).
2. Cuando hay suficientes, hace click en "Iniciar".
3. Para cada pregunta:
   - El panel muestra la pregunta, las opciones y la barra de tiempo.
   - Al cerrar la ventana, el panel muestra el conteo por opción y la correcta.
   - El docente comenta en voz alta (Zoom) y hace click en "Siguiente".
4. Al terminar la última pregunta, el panel muestra el podio.

## Post-clase

1. Hace click en "Cerrar sala".
2. Los datos se descartan. No hay historial.

## Estados del panel

    [lobby] --Iniciar--> [question_open] --tiempo agotado--> [question_closed]
                                                                    |
                                                          Siguiente |
                                                                    v
                                                          [question_open] (siguiente)
                                                                    |
                                                          (última)  v
                                                               [finished] --Cerrar--> [closed]

## Consideraciones

- El panel del docente es también vanilla, pero puede permitirse algo más de
  peso que el del alumno (el docente no compite con Zoom en la misma máquina
  *si* comparte pantalla desde un equipo dedicado; en la práctica sí compite,
  así que se mantiene liviano).
- El docente necesita ver el ranking para narrar la clase.