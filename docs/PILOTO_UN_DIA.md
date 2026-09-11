# Piloto de un día (K-01)

Receta corta para **validar Código Germinación** en un proyecto real de ~un día laboral.  
**K-01 permanece abierto** hasta que un piloto se complete y se anoten tiempos **reales** en bitácora. No inventar minutos.

Ritmo: **demo rápido** (`docs/MODO_DEMO.md`). Remoto: el marcado en `PROJECT_PROFILE.md` (GitHub **o** GitLab).

## Alcance del día

- Clarify C1–C6.
- Expediente secciones **1–8** (9–16 = N/A con motivo).
- TASKS **T01–T06** (T07 solo si hay canal APK directo y da tiempo).
- APK instalado en **teléfono físico** si el perfil es Android.
- Bitácora con inicio/fin **reales** de cada bloque.

## Orden sugerido (8 h de calendario, no de estimación)

Ajustar al reloj real. Los bloques son **nombres de trabajo**, no minutos inventados.

1. **Clarify + perfil** — C1–C6, plataforma, nube/local, remoto GitHub o GitLab.
2. **Specify + challenge** — expediente 1–8; reglas del flujo crítico.
3. **Plan** — TASKS T01–T07; `.gitignore` / `.env` sin secretos.
4. **T01 scaffold** — app corre / artefacto instalable.
5. **T02 CI** — pipeline PASS en el remoto elegido (copia `.gitlab-ci.yml` **o** `.github/workflows/ci.yml`).
6. **T03–T05** — seed/rules, smoke, auth + tests del núcleo.
7. **T06** — flujo crítico en el dispositivo del perfil (Android → APK en el teléfono).
8. **Cierre del día** — REGISTRO, CHECKLIST, bitácora (totales reales). Si APK: T07 o dejarlo TODO con motivo.

## Qué anotar (para cerrar o afinar K-01)

En `BITACORA_DESARROLLO.md`, por bloque: hora inicio, hora fin, qué se logró, qué rozó (CI, keystore, teléfono, docs).

Tras el piloto: actualizar `docs/DEUDA_CODIGO_GERMINACION.md` (cerrar K-01 o abrir ítems nuevos). **No** marcar K-01 cerrado desde esta receta.

## Fuera de alcance del piloto

Producción, manual por rol, anexos 17–20, T08+, CD automático. CD opcional: `docs/PUBLISH_APK.md` (job manual).

