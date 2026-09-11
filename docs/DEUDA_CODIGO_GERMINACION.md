# Deuda y roces conocidos de Código Germinación

Documento de **mantenimiento de Código Germinación** (no de una app de cliente).

| Tipo | Dónde va | Cuándo se actualiza |
|---|---|---|
| Error/patrón de **un proyecto** (generalizado) | `docs/LECCIONES_APRENDIDAS.md` | Al cerrar el proyecto o al repetir el síntoma (regla `13`) — **no es automático** |
| Roce / deuda / limpieza de **Código Germinación** | **Este archivo** | Cuando se detecte o se cierre un ítem al editar Código Germinación |
| Progreso de un proyecto concreto | `CHECKLIST.md` + `BITACORA_DESARROLLO.md` | Cada sesión |

Las lecciones **no se rellenan solas**. El asistente (o el profesor) debe volcar el patrón.  
Este archivo evita mezclar "arreglar el molde" con "lección de una app".

**Versión de Código Germinación al último repaso:** 2.16 (2026-09-08)

---

## Cómo usar

1. Al rozar con Código Germinación en un proyecto real → añadir fila aquí (si es del molde) **y/o** ficha en lecciones (si es patrón de app).
2. Al redistribuir una versión nueva → revisar ítems `abierto` y subir `KIT_VERSION.md` si se cerraron varios.
3. No borrar historial: marcar `cerrado` con versión/fecha.

---

## Roces abiertos (post 2.4)

| ID | Roce | Impacto | Qué hacer | Estado |
|---|---|---|---|---|
| K-01 | Validar Código Germinación en **una demo real** de un día (APK + remoto GitHub o GitLab + expediente demo) | Alto — mide velocidad/cobro de verdad | Correr un proyecto piloto (`docs/PILOTO_UN_DIA.md` + `docs/MODO_DEMO.md`); anotar **tiempos reales** en bitácora; cerrar o abrir ítems según roce. **Sigue abierto en 2.12** (GitHub+GitLab y modo demo plantillados; falta el piloto) | abierto |
| K-02 | Plugin GitHub **o** GitLab en Cursor requiere auth; runners/imagen de los examples pueden no coincidir con el grupo | Medio — CI no arranca "de fábrica" | Documentar en el piloto: remoto elegido, imagen real, tags de runner, variables; ajustar el example. **Sigue abierto en 2.12** (el molde ya admite GitHub Actions y GitLab CI) | abierto |

---

## Cerrados (historial de Código Germinación)

| ID | Roce | Cerrado en | Nota |
|---|---|---|---|
| K-06 | CD (publicar APK a Storage tras CI) no estaba plantillado, solo descrito | **2.12** | Job `publish_apk` GitLab `when: manual` (comentado) + stub GitHub `workflow_dispatch`; `docs/PUBLISH_APK.md` → `scripts/upload_apk.ps1` |
| K-03 | local-first vs prueba producto | **2.9** | Local = schema/rules; producto = dispositivo del perfil (`RECETA`, WORKFLOW 2D, CHECKLIST) |
| K-04 | Nombre regla `07-stitch-mcp-*` | **2.9** | Renombrada a `07-stitch-md-implementacion.mdc` |
| K-05 | `CONECTAR_STITCH_MCP.md` confuso | **2.9** | Stub de 1 pantalla → `COMO_USAR_EN_STITCH.md` |
| — | Orden CI / seed / DONE / APK universal / tests "si existen" | **2.9** | Orden canónico unificado; DONE por plataforma; tests núcleo en T05/T06 |
| — | Stitch MCP / ID de proyecto como puerta | 2.2 | MD-first + HTML manual al final |
| — | CI opcional en demo vs CI siempre | 2.4 | CI siempre en el remoto del perfil; ritmo solo profundiza docs |
| — | Chrome / AVD / Telefono_2 como entorno estándar | 2.2 | Teléfono + APK + auto-update (Android) |
| — | Expediente opcional / ambiguo en demo | 2.4 / **2.12** | Siempre; demo 1–8 (9–16 N/A con motivo) / completo 1–20 |
| — | Auto-update "opcional" con APK directo | 2.3 | Obligatorio si hay canal APK |

---

## Relación con lecciones aprendidas

- Si en el piloto falla **runner / imagen / plugin** del remoto elegido → cerrar o afinar **K-02** aquí; si el patrón es "CI Flutter mal tipada", además ficha `[General]`/`[Flutter]` en lecciones.
- **No** duplicar párrafos largos en ambos sitios: Código Germinación se arregla aquí; el hábito del desarrollador va a lecciones.

---

## Checklist al cerrar un roce

- [ ] Ítem marcado `cerrado` con versión  
- [ ] Archivos de Código Germinación actualizados (sin dejar la contradicción)  
- [ ] `KIT_VERSION.md` subido si el cambio se redistribuye  
- [ ] Si aplica: 1 línea en historial de `KIT_VERSION.md`  

