# Formato del archivo de quiz

Archivo JSON único, cargado al arrancar el servidor desde `QUIZ_PATH`.

## Estructura

```json
{
  "id": "utn-so-2026",
  "title": "Introducción a Sistemas Operativos",
  "version": 1,
  "questions": [
    {
      "id": "q1",
      "text": "¿Qué comando de Linux lista los archivos de un directorio?",
      "options": [
        { "id": "a", "text": "`ls`" },
        { "id": "b", "text": "`cd`" },
        { "id": "c", "text": "`rm`" },
        { "id": "d", "text": "`mv`" }
      ],
      "correctId": "a",
      "durationMs": 20000
    }
  ]
}
```

## Reglas de validación (al arrancar)

Fallos **bloqueantes** (el servidor no arranca):

- JSON malformado.
- `version` distinto de `1`.
- `id` o `title` vacíos.
- `questions` vacío.
- `id` de pregunta duplicado.
- `text` vacío.
- `options` con menos de 2 o más de 4 elementos.
- `id` de opción duplicado dentro de una pregunta.
- `correctId` que no existe en `options`.
- `durationMs` ≤ 0 o > 120 000 (2 minutos).
- Error de sintaxis Markdown en `text` o en cualquier `options[].text`
  (ver ADR-0010).

Advertencias (log, pero arranca):

- Pregunta con más de 2 000 caracteres.
- Quiz con más de 50 preguntas.
- Constructos HTML crudos en el Markdown (se escapan igual).

## Markdown

`text` de preguntas y opciones admite el subconjunto de ADR-0010:

- `**negrita**`, `*itálica*` o `_itálica_`
- `` `código inline` ``
- ` ```bloques de código``` `
- `[texto](https://...)`
- Saltos de línea con `\n`

No se soportan listas, imágenes, encabezados, tablas, HTML crudo ni anidamiento.
Si un quiz los usa, el parser devuelve error con el `id` de la pregunta y el
campo afectado.

## Ejemplo con markdown técnico

```json
{
  "id": "q7",
  "text": "Dado el siguiente código:\n```go\nfunc main() {\n  fmt.Println(2+2)\n}\n```\n¿Qué imprime?",
  "options": [
    { "id": "a", "text": "`4`" },
    { "id": "b", "text": "`\"4\"`" },
    { "id": "c", "text": "Error de compilación" },
    { "id": "d", "text": "`nil`" }
  ],
  "correctId": "a",
  "durationMs": 25000
}
```

En este ejemplo, `text` se parsea a:

```json
[
  {"t":"text","c":"Dado el siguiente código:\n"},
  {"t":"codeblock","c":"func main() {\n  fmt.Println(2+2)\n}"},
  {"t":"text","c":"\n¿Qué imprime?"}
]
```