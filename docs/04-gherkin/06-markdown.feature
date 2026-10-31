# language: es

Característica: Render de Markdown en preguntas y opciones

  Antecedentes:
    Dado que el quiz tiene una pregunta con markdown técnico

  Escenario: El servidor parsea markdown a AST al cargar el quiz
    Cuando el servidor arranca con un quiz válido
    Entonces cada `text` de pregunta y opción es un array de nodos AST
    Y no hay strings de markdown en el estado de la sala

  Escenario: Un quiz con sintaxis inválida impide arrancar
    Dado un quiz con `**sin cerrar` en una pregunta
    Cuando el servidor intenta arrancar
    Entonces falla con un mensaje que identifica el `id` de la pregunta
    Y el servidor no queda escuchando

  Escenario: El cliente no ejecuta HTML del contenido
    Dado que una pregunta contiene `<script>alert(1)</script>` como texto
    Cuando el cliente renderiza la pregunta
    Entonces el texto aparece literal, escapado
    Y no se ejecuta ningún script

  Escenario: Link con esquema no permitido se rechaza al cargar
    Dado un quiz con un link `[x](javascript:alert(1))`
    Cuando el servidor intenta arrancar
    Entonces falla la validación del quiz

  Escenario: Bloques de código preservan saltos
    Dado una pregunta con ``` `` ```go\nfmt.Println(1)\n`` ``` ``
    Cuando el cliente la renderiza
    Entonces el bloque aparece en `<pre><code>` con saltos preservados

  Escenario: El cliente renderiza código inline
    Dado una pregunta con `` ¿Qué hace `ls`? ``
    Cuando el cliente la renderiza
    Entonces "ls" aparece dentro de `<code>`

  Escenario: Nickname nunca se renderiza como markdown
    Dado un alumno con nickname "**Ana**"
    Cuando el cliente lo muestra en el ranking
    Entonces aparece literalmente "**Ana**", sin negrita