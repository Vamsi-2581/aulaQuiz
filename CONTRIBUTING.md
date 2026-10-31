# Cómo contribuir

Gracias por querer sumarte. Este documento asume **cero experiencia previa**
colaborando en proyectos open source. Si ya sabés git y PRs, podés saltear
directo a [Convenciones](#convenciones) y [Flujo de trabajo](#flujo-de-trabajo).

Si sos un agente de IA, **leé primero [`AGENTS.md`](./AGENTS.md)**. Este archivo
es para humanos; `AGENTS.md` tiene las restricciones duras.

---

## Índice

1. [Antes de empezar](#antes-de-empezar)
2. [Glosario mínimo de git/GitHub](#glosario-mínimo-de-gitgithub)
3. [Primera contribución paso a paso](#primera-contribución-paso-a-paso)
4. [Flujo de trabajo](#flujo-de-trabajo)
5. [Convenciones](#convenciones)
6. [Cómo mantener tu rama actualizada](#cómo-mantener-tu-rama-actualizada)
7. [Qué esperar de la revisión](#qué-esperar-de-la-revisión)
8. [Reglas de convivencia](#reglas-de-convivencia)

---

## Antes de empezar

1. **Leé el alcance**: [`docs/01-requerimientos/alcance.md`](./docs/01-requerimientos/alcance.md).
   Muchas ideas ya están decididas como "fuera de alcance para v1".
2. **Leé las restricciones duras**: [`AGENTS.md`](./AGENTS.md) sección 2 y 3.
   Aplican también a humanos.
3. **Buscá un issue abierto** con etiqueta `good first issue` o `help wanted`.
   Si querés proponer algo nuevo, abrí un issue **antes** de escribir código.
4. **No hay deadline ni presión.** Este es un proyecto docente. Si desaparecés
   dos semanas, no pasa nada.

---

## Glosario mínimo de git/GitHub

Si ya conocés esto, salteá esta sección.

- **Repositorio (repo)**: el proyecto. El original vive en `github.com/<owner>/aulaquiz`.
- **Fork**: una copia del repo bajo *tu* cuenta de GitHub. Sirve para no tocar
  el original. Es como "hacer una copia en tu Google Drive".
- **Clone**: traer el repo (original o tu fork) a tu máquina. `git clone <url>`.
- **Rama (branch)**: una línea de trabajo paralela. `main` es la principal; no
  se toca directamente. Cada feature/fix va en su propia rama.
- **Commit**: un punto de guardado con un mensaje. `git commit -m "..."`.
- **Push**: subir tus commits de tu máquina a GitHub. `git push`.
- **Pull Request (PR)**: una propuesta formal de "quiero que estos commits
  entren a `main`". Se abre desde la web de GitHub y pasa por revisión.
- **Review**: el proceso donde alguien (el maintainer) lee tu PR y comenta.
- **Merge**: aceptar el PR e incorporarlo a `main`.
- **Upstream**: el repo original (el del maintainer). Se agrega como remoto
  para mantener tu fork actualizado.
- **Rebase**: reaplicar tus commits sobre la versión más nueva de `main`.
  Se usa para mantener la historia limpia antes del merge.

---

## Primera contribución paso a paso

### Paso 1 — Forkear el repo

En `github.com/<owner>/aulaquiz`, click en **"Fork"** (arriba a la derecha).
Esto crea `github.com/<tu-usuario>/aulaquiz`.

> Si sos colaborador con acceso de escritura, podés saltear el fork y clonar
> el original directamente. Pero el flujo recomendado sigue siendo fork →
> rama → PR, para mantener `main` protegida.

### Paso 2 — Clonar tu fork

```bash
git clone https://github.com/<tu-usuario>/aulaquiz.git
cd aulaquiz
```

### Paso 3 — Configurar el upstream (el repo original)

```bash
git remote add upstream https://github.com/<owner>/aulaquiz.git
git remote -v
# origin    https://github.com/<tu-usuario>/aulaquiz.git (fetch)
# origin    https://github.com/<tu-usuario>/aulaquiz.git (push)
# upstream  https://github.com/<owner>/aulaquiz.git (fetch)
# upstream  https://github.com/<owner>/aulaquiz.git (push)
```

### Paso 4 — Configurar tu identidad (una sola vez)

```bash
git config --global user.name "Tu Nombre"
git config --global user.email "tu@email.com"
```

Usá el mismo email que tenés en GitHub. Si no, tus commits no se te van a
atribuir en el repo.

### Paso 5 — Crear una rama para tu cambio

```bash
git checkout -b feat/nombre-corto
```

Convención de nombres de rama:
- `feat/<algo>` — nueva funcionalidad.
- `fix/<algo>` — corrección de bug.
- `docs/<algo>` — solo documentación.
- `refactor/<algo>` — refactor sin cambio de comportamiento.
- `test/<algo>` — solo tests.

### Paso 6 — Hacer el cambio

Editá los archivos. Corré los tests:

```bash
go test ./...
go vet ./...
gofmt -l .   # no debe listar nada
```

### Paso 7 — Commitear

```bash
git add archivo1.go archivo2.go docs/...
git status              # revisar qué estás por commitear
git commit -m "feat(room): agregar reconexión con snapshot"
```

**No uses `git add .` a ciegas.** Revisá siempre `git status` antes de commitear.

### Paso 8 — Pushear tu rama

```bash
git push -u origin feat/nombre-corto
```

La primera vez con `-u` para que git recuerde la relación entre tu rama local
y la remota. Las siguientes veces alcanza con `git push`.

### Paso 9 — Abrir el Pull Request

En GitHub, después del push, aparece un cartel **"Compare & pull request"**.
Click ahí. Si no aparece:

1. Andá a tu fork en GitHub.
2. Vas a ver un banner "feat/nombre-corto had recent pushes" con un botón
   "Compare & pull request".
3. O andá a **Pull requests → New pull request** y elegí tu rama contra
   `main` del repo original.

Llená la plantilla del PR (se autocompleta con `.github/PULL_REQUEST_TEMPLATE.md`).
Asegurate de:

- Describir **qué** cambia y **por qué** (linkeá el issue).
- Marcar los checkboxes de la plantilla.
- Verificar que el CI pase (aparece al pie del PR).

### Paso 10 — Responder a la revisión

El maintainer va a comentar. Podés:

- Hacer cambios en tu rama, commitear y pushear (se actualiza el PR solo).
- Responder comentarios.
- Marcar conversaciones como resueltas cuando estén resueltas.

No hace falta "reabrir" nada ni crear otro PR. Todo se actualiza solo.

### Paso 11 — Merge

Cuando el PR está aprobado y el CI verde, el maintainer hace **squash merge**
(todos tus commits se colapsan en uno en `main`). No tenés que hacer nada.

Después del merge podés borrar tu rama local y en tu fork:

```bash
git checkout main
git pull upstream main
git branch -d feat/nombre-corto
git push origin --delete feat/nombre-corto
```

---

## Flujo de trabajo

Resumen de lo que ya cubrimos arriba, en formato checklist:

1. [ ] Leer `AGENTS.md` (secciones 2 y 3) y `docs/01-requerimientos/alcance.md`.
2. [ ] Buscar o abrir un issue.
3. [ ] Forkear (si no sos colaborador con acceso).
4. [ ] Clonar tu fork.
5. [ ] `git remote add upstream ...`.
6. [ ] `git checkout -b <tipo>/<nombre>`.
7. [ ] Cambiar el código + tests + docs en el mismo PR.
8. [ ] `go test ./...`, `go vet ./...`, `gofmt -l .`.
9. [ ] Commits con Conventional Commits.
10. [ ] `git push -u origin <rama>`.
11. [ ] Abrir PR con la plantilla.
12. [ ] Responder review.
13. [ ] Squash merge (lo hace el maintainer).

---

## Convenciones

### Commits

Formato: `tipo(alcance): descripción en presente, minúsculas, sin punto final`.

Tipos válidos: `feat`, `fix`, `docs`, `test`, `refactor`, `chore`, `ci`, `perf`.

Ejemplos:
- `feat(room): aceptar reconexión con sessionToken`
- `fix(scoring): corregir bonus cuando elapsed > duration`
- `docs(adr): agregar ADR-0010 sobre snapshot parcial`
- `test(protocol): cubrir rechazo por nickname duplicado`

### Código Go

- `gofmt` aplicado (el CI lo verifica).
- `go vet` sin warnings.
- Errores envueltos con `%w`.
- Sin `init()`, sin globales mutables.
- Dominio (`internal/domain`) puro, sin red.

### Frontend

- Sin frameworks, sin build step, sin CDNs.
- Un `.html`, un `.css`, un `.js` por pantalla.
- Sin `innerHTML` con datos del usuario.

### Documentación

- Toda decisión arquitectónica → ADR en `docs/03-adr/`.
- Todo comportamiento observable → feature Gherkin en `docs/04-gherkin/`.
- Toda feature nueva → actualizar `docs/01-requerimientos/` si aplica.
- Markdown con un solo H1 por archivo, links relativos.

---

## Cómo mantener tu rama actualizada

Si `main` avanzó mientras trabajabas en tu rama, actualizá antes de pedir review:

```bash
git fetch upstream
git checkout feat/nombre-corto
git rebase upstream/main
# resolver conflictos si hay
git push --force-with-lease
```

`--force-with-lease` es seguro: solo sobreescribe si nadie más pusheó a tu rama
mientras tanto. **Nunca uses `--force` a secas.**

Si el rebase te da miedo, podés usar `git merge upstream/main` (crea un commit
de merge). El maintainer va a hacer squash igual, así que no importa tanto.

---

## Qué esperar de la revisión

- **Tiempo**: el maintainer revisa cuando puede. Si pasaron 7 días sin respuesta,
  comentá en el PR (un ping amable, no un "hola???").
- **Feedback**: puede haber pedidos de cambio. No es personal, es mejorar el PR.
- **Criterios de aceptación**:
  - Cumple `AGENTS.md` (restricciones duras).
  - Está dentro del alcance.
  - Tiene tests.
  - Tiene docs actualizadas.
  - CI verde.
  - Commits razonables (el squash los colapsa igual).

---

## Reglas de convivencia

- Respetá el [Código de Conducta](./CODE_OF_CONDUCT.md).
- Asumí buena fe. Los comentarios en texto pierden tono.
- Si no entendés un pedido de cambio, preguntá. No adivines.
- Si el PR se estanca, está bien cerrarlo y volver después.
- Si encontrás un bug mientras trabajás en otra cosa, **abrí un issue separado**, no lo arregles "de paso" en el PR actual (scope creep).