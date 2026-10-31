# ADR-0010 — Soporte de Markdown en preguntas y opciones

- **Estado:** aceptado
- **Fecha:** 2026-10-31

## Contexto

Los quizzes de la cátedra son técnicos (código, GADs, expresiones). Necesitamos
formato en preguntas y opciones: negrita, itálica, código inline, bloques de
código, links. Sin esto, los quizzes se ven planos y pierden legibilidad.

Restricciones vigentes:
- Cliente sin frameworks ni dependencias (ADR-0003).
- Sin `innerHTML` con datos de usuario (AGENTS.md).
- Bundle gzipped < 150 KB (RNF-02).
- XSS debe ser imposible por construcción, no por sanitización.

## Decisión

Soportar un **subconjunto** de Markdown, con **parseo server-side a AST** y
**render client-side por construcción de nodos DOM** (nunca `innerHTML`).

### Subconjunto soportado (v1)

| Constructo | Sintaxis | Nodo AST |
|---|---|---|
| Negrita | `**texto**` | `bold` |
| Itálica | `*texto*` o `_texto_` | `italic` |
| Código inline | `` `código` `` | `code` |
| Bloque de código | ` ``` ... ``` ` | `codeblock` |
| Link | `[texto](https://...)` | `link` |
| Salto de línea | `\n` | dentro de `text` |

### No soportado (v1)

- HTML crudo (siempre se escapa).
- Imágenes.
- Listas (numeradas o con viñetas).
- Encabezados.
- Tablas, blockquotes, reglas horizontales.
- Anidamiento (negrita dentro de itálica, etc.).
- URLs sueltas sin `[texto](url)`.
- URLs con esquema distinto de `http`/`https`.

Estas limitaciones están documentadas y pueden ampliarse en v2 vía ADR.

### Flujo

1. **Autoría**: el `quiz.json` contiene `text` como string Markdown.
2. **Carga**: al arrancar, `internal/markdown.Parse` valida y convierte a AST.
   Si hay error de sintaxis (backticks o `**` sin cerrar, link sin `)`), el
   servidor **no arranca** con un mensaje claro.
3. **Broadcast**: el AST viaja en `question.show` / `room.snapshot`. El string
   Markdown original **no se envía al cliente**.
4. **Render**: `web/render-ast.js` recorre el AST y crea nodos DOM con
   `document.createTextNode` y `document.createElement`. Nunca `innerHTML`.
5. **Links**: `href` validado server-side (solo `http`/`https`); el cliente
   agrega `rel="noopener noreferrer"` y `target="_blank"`.

### Seguridad

- **No hay superficie de XSS**: todo el texto termina en `textContent` de un
  nodo. Los únicos elementos creados son `strong`, `em`, `code`, `pre`, `a`,
  `br`, `span`, y `a` tiene `href` validado.
- **No hay carga de recursos externos**: no se soportan imágenes ni iframes.
- **DoS**: el parser rechaza contenido con más de 1.000 nodos por campo o más
  de 4 KB de texto fuente.

## Justificación

- Mantiene el cliente sin parser de markdown (menos código, menos bugs).
- Elimina la superficie de XSS por construcción.
- No agrega dependencias: ~150 líneas de Go en `internal/markdown` y ~80
  líneas de JS en `web/render-ast.js`.
- Payload extra: ~2–4x el tamaño del string Markdown. Para 200 clientes y
  10 preguntas, menos de 100 KB adicionales en toda la partida.
- Cero requests externos.

## Consecuencias

- Positivas: quizzes técnicos legibles; seguridad demostrable; código acotado.
- Negativas: autores limitados a un subconjunto. Si un docente quiere tablas
  o imágenes, hay que ampliar el AST y el renderer (ADR nuevo).
- Negativas: errores de sintaxis en `quiz.json` impiden arrancar. Es deseable:
  mejor fallar temprano con mensaje claro que broadcast silencioso de texto roto.

## Alternativas consideradas

- **marked.js / markdown-it en cliente**: agrega 30–50 KB gzipped, viola ADR-0003
  (sin dependencias) y reintroduce superficie de XSS.
- **Renderer server-side a HTML + sanitizer**: requiere sanitizer (otra
  dependencia), `innerHTML` en cliente (viola AGENTS.md), y el HTML ocupa más
  que el AST.
- **Texto plano**: descartado, los quizzes técnicos pierden legibilidad.
- **Rich text JSON estructurado a mano**: menos amigable para autores que
  Markdown.

## Presupuesto

- `internal/markdown`: ~150 líneas Go.
- `web/render-ast.js`: ~80 líneas JS, ~2 KB gzipped.
- RNF-02 se mantiene en 150 KB totales.