# Política de seguridad

## Alcance

`aulaquiz` es un proyecto docente sin fines comerciales. **No maneja datos
sensibles persistentes**: no hay cuentas, no hay historial, no hay base de
datos. El estado de una partida vive en memoria del servidor y se descarta al
cerrar la sala. El registro es efímero (nickname + email institucional opcional).

Aun así, nos importan los problemas de seguridad. Las superficies de ataque
relevantes son:

- Inyección en el cliente (XSS) vía nickname o textos de pregunta.
- Denegación de servicio (saturación de WebSockets, mensajes gigantes).
- Fuga de estado entre salas.
- Manipulación del protocolo para alterar puntajes o ranking.

## Cómo reportar

**No abras un issue público para reportar una vulnerabilidad.**

Escribí a `<email-del-maintainer>` con:

- Descripción del problema.
- Pasos para reproducirlo.
- Impacto estimado.
- Versión/commit afectado.
- Si querés, una propuesta de mitigación.

## Qué esperar

- Acuse de recibo en un plazo razonable (esto es un proyecto a pulmón; sé paciente).
- Evaluación y, si aplica, fix.
- Crédito en el commit o en el release notes, si querés.
- No habrá recompensa económica (no hay presupuesto).

## Divulgación

Pedimos que no divulgues públicamente el problema hasta que exista un fix
disponible o hayan pasado 90 días desde el reporte, lo que ocurra primero.