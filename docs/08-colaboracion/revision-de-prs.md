# Revisión de PRs

Guía para el maintainer y para quien revise PRs (incluido el auto-chequeo
antes de pedir review).

## Checklist del revisor

### Coherencia con el proyecto

- [ ] ¿El cambio está dentro del alcance (`docs/01-requerimientos/alcance.md`)?
- [ ] ¿Viola alguna restricción dura de `AGENTS.md` sección 2 o 3?
- [ ] ¿La solución propuesta es la más simple posible para el problema?

### Código

- [ ] ¿Hay tests para el comportamiento nuevo?
- [ ] ¿Los tests testean comportamiento, no implementación?
- [ ] ¿Hay manejo de errores adecuado (no `_ = err`)?
- [ ] ¿El dominio (`internal/domain`) sigue puro (sin imports de red)?
- [ ] ¿Se respetan las convenciones de `CONTRIBUTING.md`?
- [ ] ¿No hay código muerto, comentarios obvios, o `TODO` sin issue?

### Frontend (si aplica)

- [ ] ¿Se mantiene sin frameworks, sin build step, sin CDNs?
- [ ] ¿El bundle gzipped sigue por debajo de 150 KB?
- [ ] ¿Las animaciones usan `transform`/`opacity`?
- [ ] ¿Respeta `prefers-reduced-motion`?
- [ ] ¿No hay `innerHTML` con datos del usuario?

### Documentación

- [ ] ¿Se actualizó la feature Gherkin si cambió comportamiento observable?
- [ ] ¿Se actualizó el protocolo WebSocket si cambió el contrato?
- [ ] ¿Hay ADR si tomó una decisión arquitectónica?
- [ ] ¿Se actualizó el roadmap si corresponde?

### Proceso

- [ ] ¿Los commits siguen Conventional Commits?
- [ ] ¿El PR está atado a un issue (`Closes #...`)?
- [ ] ¿No hay scope creep? (cambios fuera del issue)
- [ ] ¿El CI está verde?

## Cómo dejar feedback

- **Bloqueante**: `[blocking]` al inicio del comentario. Algo que debe cambiar antes del merge.
- **Sugerencia**: `[suggestion]` o "nit:". Mejora opcional.
- **Pregunta**: `[question]`. Para entender la intención antes de opinar.
- **Aprobación con notas**: "Apruebo, pero considerá X para un próximo PR."

Sé específico. "Esto está mal" no ayuda. "Esta función podría devolver error
en vez de panic cuando el input es vacío, porque..." sí.

## Cuándo rechazar un PR

- Viola una restricción dura.
- Está fuera de alcance y no hay issue aprobado.
- No tiene tests y el comportamiento es no trivial.
- Scope creep significativo (arregla el issue + 3 cosas más).
- El autor no responde tras 30 días y hay conflictos.

Rechazar no es fracasar. Un PR rechazado con explicación clara es mejor que un
PR mergeado que rompe el diseño.