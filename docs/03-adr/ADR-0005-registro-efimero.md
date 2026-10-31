# ADR-0005 — Registro efímero del alumno

- **Estado:** aceptado

## Contexto

Necesitamos identificar a cada alumno en la sala para asignar puntaje y mostrar
ranking, pero no queremos construir un sistema de cuentas, ni manejar datos
personales más allá de lo mínimo, ni agregar fricción al join.

## Decisión

Registro **efímero** con:
- **Nickname obligatorio** (1–20 caracteres, único en la sala).
- **Email institucional opcional**, no validado, no usado para lookup.

Los datos viven solo mientras la sala existe. No se persisten en disco. Al
cerrar la sala, se descartan.

## Justificación

- Minimiza datos personales (principio de minimización).
- Elimina la necesidad de autenticación, recuperación de contraseña, etc.
- El nickname es suficiente para que el alumno se reconozca en el ranking.
- El email opcional permite al docente tener un identificador si lo necesita
  para el aula, sin obligar a nadie a darlo.

## Consecuencias

- Positivas: fricción mínima en el join (segundos), cero gestión de cuentas.
- Negativas: no hay forma de evitar que un alumno use el nickname de otro
  si el primero se desconecta más de 60 s. Aceptable: no hay anti-cheating
  en v1 por decisión explícita.

## Alternativas consideradas

- **OAuth con Google institucional:** sobredimensionado, agrega dependencia
  externa y fricción, y contradice el requisito de cliente liviano.
- **Solo email obligatorio:** agrega fricción y no aporta valor al juego.