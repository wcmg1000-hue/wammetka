# Guía para el profesor

## Objetivo de Código Germinación

Enseñar un flujo profesional y rápido: decisiones adaptativas, MD-first, APK en teléfono, bitácora de horas, staging/producción recuperable.

## Preparación única

- Instalar Git y runtimes del stack (Flutter, Firebase/Supabase CLI).
- **CI obligatoria en el remoto del perfil: GitHub Actions o GitLab CI** (marcar uno). Plugin Cursor del remoto elegido; CD opcional (`docs/CI_CD.md`).
- **Expediente técnico siempre** (demo 1–8, 9–16 N/A con motivo / completo 1–20). Demo: `docs/MODO_DEMO.md`.
- Roces de Código Germinación: `docs/DEUDA_CODIGO_GERMINACION.md` (manual). Lecciones de apps: `LECCIONES_APRENDIDAS.md` al cerrar proyecto.
- **No** Stitch MCP: MD pegable + HTML manual al final.
- Descubrimiento: plataforma + nube/local; APK directo → auto-update obligatorio.
- Credenciales privilegiadas nunca en chats ni en el cliente.

## Flujo de clase

1. Idea → **Clarify** → **Specify** → **`CG.challenge`** (reglas flujo crítico).
2. **Plan** (`TASKS.md` T01…) + camino D1/D2.
3. Rebanada = primeras tareas → APK en teléfono + auto-update.
4. Orden canónico `RECETA_MENOS_REWORK.md` (scaffold→CI→seed→auth→flujo); DONE en dispositivo del perfil → `CG.converge`.
5. Staging / producción según alcance.
6. Manuales, expediente, totales de horas, lecciones.

## Rutas

- V1 Stitch: MD → implementar → APK teléfono; HTML manual solo al final del visual.
- V2 / V3 / V4: según perfil.
- D1–D2: `CAMINO_POR_STACK.md`; D5 omite datos.

## Qué se evalúa

- El alcance está claro y el flujo crítico funciona.
- Git + CI del remoto elegido permiten detectar/regresar errores.
- Permisos se prueban con casos permitidos y denegados.
- No se usan datos productivos para desarrollar.
- Cada PASS tiene evidencia reproducible.
- Staging representa producción.
- Producción tiene monitoreo, backup/restore cuando aplica y rollback.
- La documentación refleja lo construido, no intenciones.

## Señales de alerta

- Crear todas las pantallas antes de probar un flujo completo.
- Elegir Flutter, Stitch o Firebase sin justificarlo.
- Probar directamente contra producción.
- Ocultar botones como único control de autorización.
- Marcar checks sin ejecutar comandos.
- Desactivar pruebas para poner CI verde.
- Guardar service role, claves privadas o keystores en el repo/app.
- Publicar sin smoke test ni rollback.

La regla pedagógica central es: pequeño, completo, verificable y recuperable.

Piloto de un día (K-01, sigue abierto): `docs/PILOTO_UN_DIA.md`.

