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
| 2026-09-11 | T05 Auth | build APK arm64 + dart-define | `flutter build apk --release --target-platform android-arm64 --build-name=0.1.0 --build-number=2 --dart-define-from-file=dart_defines.apk.json` | PASS (17.7 MB) | local | `entregas/apk/wammetka-v0.1.0+2-arm64.apk` | defines cliente; sin seed/service_role |
| 2026-09-11 | T01/T05 | adb devices | `adb devices -l` | PASS — teléfono físico | 68486ddd · sapphire · 23129RA5FL | no emulador | Redmi conectado |
| 2026-09-11 | T01/T05 | install APK | `adb -s 68486ddd install -r …v0.1.0+2-arm64.apk` | FAIL `INSTALL_FAILED_USER_RESTRICTED` | teléfono | artefacto +2 | Xiaomi canceló/bloqueó USB install. **T01/T05 no DONE** |
| 2026-09-11 | T05 Auth | smoke login teléfono | no ejecutado | FAIL — APK no instalada | — | — | No se observó login `cliente@wammetka.test` |
| 2026-09-11 | T04 Smoke | escritura cloud desde dispositivo | no ejecutado | FAIL — APK no instalada | — | botón Guardar perfil en código | **T04 no DONE** |
| 2026-09-11 | T01/T05 | install APK | `adb -s 68486ddd install -r entregas/apk/wammetka-v0.1.0+2-arm64.apk` | PASS Success | Redmi 68486ddd | APK +2 | reintento; ya no USER_RESTRICTED |
| 2026-09-11 | T01 Scaffold | smoke teléfono | `am start` + uiautomator | PASS | Redmi 68486ddd | `co.wammetka.wammetka` | UI `Wammetka` + `Entrar a Wammetka` |
| 2026-09-11 | T05 Auth | smoke login/logout | login seed + `Cerrar sesión` | PASS | Redmi 68486ddd | `cliente@wammetka.test` | UI `Hola, Cliente Piloto` / `Rol: cliente` → vuelve a `Entrar a Wammetka` |
| 2026-09-11 | T04 Smoke | Guardar perfil | tap `Guardar perfil` | PASS | Redmi + staging | `profiles.telefono=3001234567` | UI `Perfil guardado`; SELECT cloud confirmado |

| 2026-09-11 | T06 Pedido | analyze | `flutter analyze` | PASS (exit 0, 0 issues) | local Flutter 3.47.2 | `lib/features/catalog` + `order` | consola Agent |
| 2026-09-11 | T06 Pedido | tests núcleo | `flutter test` | PASS 17 + 1 skip live | local | `test/pedido_nucleo_test.dart` + auth | AC-03/04/05/06/07/08 + no-mezclar |
| 2026-09-11 | T06 Pedido | build APK arm64 | `flutter build apk --release --target-platform android-arm64 --build-name=0.1.0 --build-number=3 --dart-define-from-file=dart_defines.apk.json` | PASS (18.3 MB) | local | `entregas/apk/wammetka-v0.1.0+3-arm64.apk` | defines cliente; sin seed |
| 2026-09-11 | T06 Pedido | install APK | `adb -s 68486ddd install -r …v0.1.0+3-arm64.apk` | PASS Success | Redmi 68486ddd | APK +3 | primer intento; no USER_RESTRICTED |
| 2026-09-11 | T06 Pedido | smoke AC-03 | cliente seed: catálogo → carrito → confirmar contraentrega | PASS | Redmi + staging | pedido `a6fb5a34-9662-46ba-908a-ff3c438a360e` | UI `Pedido enviado` / `A6FB5A34` / `$9.500 COP · Contraentrega`; SQL total 950000 = 450000+500000; estado `pendiente_comercio` |
| 2026-09-11 | T06 Pedido | smoke AC-10 | comercio seed: bandeja Nuevos → Aceptar pedido | PASS | Redmi + staging | mismo pedido | UI `Cliente Piloto` / `Nuevo` → `Aceptado` + `Marcar preparado`; evento `pendiente_comercio`→`aceptado` |
| 2026-09-11 | T06 Pedido | pipeline Actions | workflow `CI` run 4 · jobs `verify` + `build_apk` | PASS | GitHub Actions ubuntu-latest Flutter 3.47.2 | `cd22121` | https://github.com/wcmg1000-hue/wammetka/actions/runs/34659992798 |

| 2026-09-11 | T07 Update | analyze | `flutter analyze` | PASS (exit 0, 0 issues) | local Flutter 3.47.2 | `lib/features/update` | consola Agent |
| 2026-09-11 | T07 Update | tests núcleo | `flutter test` | PASS 25 + 2 skip live | local | `test/update_nucleo_test.dart` | versionCode + SHA-256 + semver fallback |
| 2026-09-11 | T07 Update | build APK arm64 | `flutter build apk --release --target-platform android-arm64 --build-name=0.1.0 --build-number=4 --dart-define-from-file=dart_defines.apk.json` | PASS (19.0 MB) | local | `entregas/apk/wammetka-v0.1.0+4-arm64.apk` | define cliente; sin seed/service_role |
| 2026-09-11 | T07 Update | install APK +4 | `adb -s 68486ddd install -r …v0.1.0+4-arm64.apk` | PASS Success | Redmi 68486ddd | APK +4 con módulo | primer intento; no USER_RESTRICTED |
| 2026-09-11 | T07 Update | remoto `app_config` | SELECT id=1 | PASS `version_code=5` | staging `wwhyypadkjjbgkmlbpss` | sha256 `811d0e7dac21593d33b9cd9326db35ee2b7db141fb1658d795143d937b561804` | URL `https://wwhyypadkjjbgkmlbpss.supabase.co/storage/v1/object/public/apk/releases/wammetka-v0.1.0+5-arm64.apk` · HEAD 200 |
| 2026-09-11 | T07 Update | smoke AC-11 | abrir app → diálogo → Actualizar ahora | PASS | Redmi 68486ddd | instalado 4 vs remoto 5 | UI `Nueva versión disponible` / `Actualizar ahora` |
| 2026-09-11 | T07 Update | smoke hash+install | descarga + SHA-256 + instalador | PASS | Redmi 68486ddd | `dumpsys` `versionCode=5` | hash local +5 = remoto (minúsculas); no mismatch; Xiaomi aviso de riesgos aceptado; reopen sin diálogo |

Solo usar `PASS` cuando el resultado haya sido observado. No guardar secretos ni datos personales.
