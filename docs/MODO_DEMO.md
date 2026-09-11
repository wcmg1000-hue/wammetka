# Modo demo rápido

Cuando `PROJECT_PROFILE.md` marca **ritmo = demo rápido**, el molde se **acota**, no se salta. La CI del remoto elegido sigue siendo obligatoria.

Ver también: `docs/PILOTO_UN_DIA.md` (piloto de un día; K-01 permanece abierto).

## Qué sí se exige

1. **Clarify C1–C6** cerrado en `PROJECT_PROFILE.md`.
2. **Expediente** `docs/EXPEDIENTE_TECNICO.md`: secciones **1–8** rellenas (pueden ser breves).
3. **TASKS** solo **T01–T07** (scaffold → CI → seed/smoke → auth → flujo → auto-update si APK). No abrir T08+ en demo.
4. **Bitácora** `docs/BITACORA_DESARROLLO.md` en cada sesión (tiempos reales; no inventar minutos).
5. CI verde en el **remoto del perfil** (GitHub Actions **o** GitLab CI).
6. Smoke en el **dispositivo del perfil**. Puerta DONE fail-closed: sin fila PASS en `docs/evidencias/REGISTRO.md` no hay `DONE`.

## Qué no se exige

- No rellenar **todas** las secciones 1–16 del expediente. Las **9–16** pueden ir como **`N/A` + una línea de motivo** (p. ej. “demo: sin producción”).
- Specs sueltos en `docs/specs/` opcionales (el expediente hace de backlog).
- Manual por rol y runbook de producción: `N/A` si se acuerda.
- Anexos 17–20: no aplican al ritmo demo.

## Cómo marcarlo

En `PROJECT_PROFILE.md` → Ritmo de entrega → **Demo rápido**.  
En el expediente: **Ritmo:** demo rápido.

## Orden mínimo

```text
CG.clarify (C1–C6)
→ CG.specify (expediente 1–8)
→ CG.challenge (flujo crítico, máx. ~6 reglas)
→ CG.plan (TASKS T01–T07)
→ T01…T06 en dispositivo del perfil
→ T07 auto-update si APK directo
→ bitácora + REGISTRO
```

Punto de entrada: `EMPEZAR_AQUI.md`. Detalle de tareas: `docs/TASKS.md`.

