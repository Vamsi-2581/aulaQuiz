# Tu primer PR: guía extendida

Esta guía complementa `CONTRIBUTING.md` con más detalle para quien nunca
abrió un PR. Si ya sabés, no la necesitás.

## Qué es un PR, en una frase

Un Pull Request es una **propuesta** de cambios. No modifica nada hasta que
alguien con permiso lo aprueba y lo mergea. Es como mandar un mail diciendo
"che, mirá estos cambios, ¿los aceptás?".

## El modelo mental
```text

[repo original] ──fork──► [tu fork] ──clone──► [tu máquina]
▲ │
│ │
└────────── PR (pull request) ◄── push ──────────────┘
```

- El **repo original** es de solo lectura para vos (salvo que seas colaborador).
- Tu **fork** es tu copia, ahí podés hacer lo que quieras.
- En **tu máquina** trabajás localmente.
- El **PR** es la propuesta de llevar tus cambios del fork al original.

## Errores comunes (y cómo salir)

### "Hice commits directo en mi fork, no en una rama"

No pasa nada. Creá la rama desde donde estás y apuntá el PR a esa rama:

```bash
git checkout -b feat/mi-cambio
git push -u origin feat/mi-cambio
```

Después reseteá tu main local al del upstream para no arrastrar los cambios:
```bash
git checkout main
git reset --hard upstream/main
git push --force-with-lease origin main
```

"Mi PR tiene conflictos con main"
```bash
git fetch upstream
git rebase upstream/main

# resolver conflictos archivo por archivo
git add archivo-resuelto
git rebase --continue
git push --force-with-lease
```

Si te trabás, podés abortar y volver al estado anterior:
```bash
git rebase --abort
```

"Commiteé un secreto / archivo enorme por error"

No lo pushees. Si ya lo pusheaste, avisá en el PR antes de que se mergee.
El maintainer puede ayudar a limpiar la historia. Si el secreto es real,
rotalo inmediatamente (aunque sea un token de prueba).

"No sé qué rama base elegir al abrir el PR"

main del repo original (<owner>:main). GitHub lo elige por defecto si
forkeaste bien.
"El CI falla y no entiendo por qué"

Mirá el log del job que falló (click en "Details"). Los más comunes:
- `gofmt`: olvidaste correr `gofmt -w .`
- `go vet`: hay un warning. Leelo, suele ser claro.
- `go test`: un test rompió. Corré `go test ./...` local y mirá qué falla.
- `frontend-budget`: agregaste algo pesado. Revisá qué archivo creció.

Si no lo resolvés, comentá en el PR con el error. No pasa nada.

Pedir ayuda

- Comentá en el issue o el PR.
- Si es una duda de git, pegá el comando y el error exacto.
- Si es una duda de diseño, linkeá al ADR o requerimiento relevante.
- Si es tu primer PR, decilo. Hay paciencia para eso.