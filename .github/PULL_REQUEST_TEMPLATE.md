## Qué cambia

<!-- Describí en 1–3 oraciones qué hace este PR. -->

## Por qué

<!-- Linkeá el issue: Closes #123 -->

Closes #

## Tipo de cambio

- [ ] Feature nueva
- [ ] Bug fix
- [ ] Refactor (sin cambio de comportamiento)
- [ ] Documentación
- [ ] Tests
- [ ] CI / tooling

## Checklist

- [ ] Leí `AGENTS.md` y mi cambio no viola ninguna restricción dura.
- [ ] Mi cambio está dentro del alcance de `docs/01-requerimientos/alcance.md`.
- [ ] Agregué/actualicé tests para el comportamiento nuevo.
- [ ] Agregué/actualicé la feature Gherkin correspondiente.
- [ ] Si toqué el protocolo WebSocket, actualicé `docs/02-arquitectura/protocolo-websocket.md`.
- [ ] Si tomé una decisión arquitectónica, agregué un ADR.
- [ ] `go test ./...` pasa localmente.
- [ ] `go vet ./...` pasa localmente.
- [ ] `gofmt -l .` no lista archivos.
- [ ] No agregué dependencias fuera de `coder/websocket` + stdlib.
- [ ] No agregué frameworks, build step, ni CDNs al frontend.
- [ ] No hay `TODO`/`FIXME` sin issue asociado.
- [ ] No hay scope creep (cambios fuera del issue que estoy resolviendo).

## Notas para el revisor

<!-- Opcional: cosas que querés que el revisor mire con más atención,
     decisiones que tomaste, alternativas que descartaste. -->