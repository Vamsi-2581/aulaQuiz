# ADR-0009 — Avatares generados localmente a partir del nickname

- **Estado:** aceptado

## Contexto

Queremos dar identidad visual a cada alumno sin:
- Permitir subida de imágenes (peso, moderación, almacenamiento).
- Hacer requests a servicios externos (DiceBear, Gravatar) que agregan
  latencia y dependencia.
- Cargar una librería de generación de avatares.

## Decisión

El avatar se **deriva determinísticamente** del nickname:
seed = hash(nickname) // FNV-1a o similar, calculado en el servidor
shape = seed % N_FORMAS // círculo, cuadrado redondeado, hexágono, etc.
color = paleta[seed % N_COLORES]
initial = primera letra del nickname en mayúscula
text


El servidor envía `avatarSeed` en el `student.joined` y en cada snapshot.
El cliente renderiza el avatar con CSS + un `<span>` para la inicial. Sin
imágenes, sin SVG generados dinámicamente, sin canvas.

## Justificación

- Determinístico: el mismo nickname siempre da el mismo avatar.
- Cero peso: son 3 números y una letra.
- Cero requests externos.
- Consistente entre reconexiones y entre cliente docente y cliente alumno.

## Consecuencias

- Positivas: identidad visual sin costo.
- Negativas: dos alumnos con el mismo nickname (imposible en la misma sala)
  tendrían el mismo avatar. No es un problema.

## Alternativas consideradas

- **DiceBear self-hosted:** agrega assets y complejidad.
- **Gravatar por email:** requiere email obligatorio y request externo.
- **Subida de imagen:** descartado por peso y moderación.

