# Comandos de verificación

Mismos comandos en local y en la CI del **remoto del perfil** (GitHub Actions o GitLab CI).  
Orden y puerta DONE: `docs/RECETA_MENOS_REWORK.md`.  
Política de jobs: `docs/CI_CD.md` (format + analyze + test en PR/MR y default; build arm64 solo en default).

Stack: Flutter + Supabase (D1). Remoto: GitHub Actions. Comandos = jobs de `.github/workflows/ci.yml`.

| Control | Comando exacto | Resultado esperado | Aplica |
|---|---|---|---|
| Formato | `dart format --set-exit-if-changed .` | exit 0 | **sí** (Flutter) — job CI en PR/MR + default |
| Lint/análisis | `flutter analyze` _(u equiv.)_ | exit 0 | **sí** — PR/MR + default |
| Tests del núcleo | `flutter test` _(3 mínimos en T05/T06: auth, no-puede / validación — `QA_MINIMO.md`)_ | exit 0 (live se salta sin dart-define) | **sí** desde rebanada — PR/MR + default |
| Login seed (opcional local) | `powershell -File tool/write_dart_defines.ps1` luego `flutter test test/auth_live_optional_test.dart --dart-define-from-file=dart_defines.local.json` | PASS login `cliente@wammetka.test` + no-puede autoascenso | **local/staging**; archivo define gitignored |
| Build artefacto | `flutter build apk --release --target-platform android-arm64` / `build web` / otro | artefacto arm64 (o split-per-abi conservando arm64) | **sí** — CI solo en rama default; local cuando haga falta |
| Rules / RLS | según stack (emulador / `supabase test db`) | +/− OK | **local Fase 2D**; job CI opcional (no en YAML base) |
| Publicar update | Storage + `version_code` + `sha256` + `apk_url` (`docs/PUBLISH_APK.md`) | teléfono detecta `versionCode` | solo APK directo |
| Pre-flight Firebase | `projects:list` + apps + DB | OK | no |
| Pre-flight Supabase | `npx supabase start` + migraciones + MCP project Wammetka | OK | **sí — T03** |
| Seed día 1 | script/SQL documentado | roles de prueba listos | sí si hay BD |
| Smoke producto | 1 acción DoD en **dispositivo del perfil** | visible / OK | **sí** |
| Smoke cloud | 1 escritura desde dispositivo → consola | documento visible | sí si nube |
| Secretos | escaneo / revisión | sin secretos en repo | sí |

## Dispositivo de prueba

1. Android APK → teléfono físico (+ auto-update). **No** Chrome/AVD como estándar.
2. Web → navegador del perfil.
3. Desktop → build nativo.
4. Copiar artefacto a la ruta de entrega del perfil cuando aplique.

## Evidencia

Cada PASS en `docs/evidencias/REGISTRO.md`: fase, comando, resultado, entorno, commit/artefacto, URL pipeline si aplica. **Sin esa fila no hay DONE.**

