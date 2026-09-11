# Registro de evidencias

| Fecha | Fase/módulo | Control | Comando/procedimiento | Resultado | Entorno | Commit/artefacto | Evidencia |
|---|---|---|---|---|---|---|---|
| 2026-09-11 | T01 Scaffold | analyze | `flutter analyze` | PASS (exit 0, 0 issues, 242.5 s) | local Windows Flutter 3.47.2 / Dart 3.13.2 | `lib/` tema + splash/login | consola Agent |
| 2026-09-11 | T01 Scaffold | tests | `flutter test` | PASS (1/1 widget splash→login) | local | `test/widget_test.dart` | consola Agent |
| 2026-09-11 | T01 Scaffold | build APK arm64 | `flutter build apk --release --target-platform android-arm64` | PASS (16.2 MB) | local | `entregas/apk/wammetka-v0.1.0+1-arm64.apk` | artefacto copiado |
| 2026-09-11 | T01 Scaffold | smoke teléfono | `adb devices` | FAIL — ningún dispositivo | — | — | `adb devices` vacío. **T01 no DONE** hasta instalar el APK en el teléfono |
| 2026-09-11 | T02 CI | crear repo GitHub | MCP `create_repository` | FAIL 404 | GitHub App `wcmg1000-hue` | — | Sin permiso para crear repos; git `main` inicializado |
| 2026-09-11 | T03 Datos | proyecto Supabase | `create_project` wammetka sa-east-1 | PASS | cloud | `wwhyypadkjjbgkmlbpss` | Distincto de otros proyectos de la org |
| 2026-09-11 | T03 Datos | migraciones + RLS | `apply_migration` init/rls/rpc/revoke | PASS | cloud | `supabase/migrations/` | RLS ON; anon_crear=false; auth_crear=true |
| 2026-09-11 | T03 Datos | seed | execute_sql municipios/zonas/users/SKU | PASS | staging | 4 users + 3 productos | correos `@wammetka.test` |
| 2026-09-11 | T02/T03 | git | `git commit` | PASS | local | `0deddf4` | primer commit en `main`; sin remoto |
| 2026-09-11 | T01 Scaffold | smoke teléfono | `adb devices` | FAIL — ningún dispositivo | — | — | Re-check; sigue vacío. **T01 no DONE** |
| 2026-09-11 | T02 CI | remoto GitHub | MCP `list_branches` + `git ls-remote https://github.com/wcmg1000-hue/wammetka.git` | FAIL 404 / exit 128 | GitHub `wcmg1000-hue` | — | Repo no existe. No se reintentó `create_repository` |
| 2026-09-11 | T03 Datos | Auth seed tokens | `UPDATE auth.users` coalesce tokens a `''` | PASS | staging | `wwhyypadkjjbgkmlbpss` | GoTrue 500 por `confirmation_token` NULL |
| 2026-09-11 | T03 Datos | GRANT helpers RLS | `apply_migration` grant_private_helpers | PASS | staging | `supabase/migrations/20260911214500_grant_private_helpers.sql` | 42501 `is_staff` resuelto |
| 2026-09-11 | T05 Auth | analyze | `flutter analyze` | PASS (exit 0) | local Flutter 3.47.2 | `lib/config` + `lib/features/auth` | consola Agent |
| 2026-09-11 | T05 Auth | tests núcleo | `flutter test` | PASS 7 + 1 skip (live sin dart-define) | local | `test/auth_nucleo_test.dart` | CI-compatible; sin secretos |
| 2026-09-11 | T05 Auth | login seed live | `flutter test test/auth_live_optional_test.dart --dart-define-from-file=dart_defines.local.json` | PASS | staging | `cliente@wammetka.test` + no-puede autoascenso | archivo define gitignored. **T05 no DONE** (falta smoke teléfono) |
| 2026-09-11 | T02 CI | push origin main | `git push -u origin main` | PASS | GitHub público | `46441d8` | https://github.com/wcmg1000-hue/wammetka |
| 2026-09-11 | T02 CI | pipeline Actions | workflow `CI` run 1 · jobs `verify` + `build_apk` | PASS | GitHub Actions ubuntu-latest Flutter 3.47.2 | `46441d8` | https://github.com/wcmg1000-hue/wammetka/actions/runs/34656548482 |

Solo usar `PASS` cuando el resultado haya sido observado. No guardar secretos ni datos personales.
