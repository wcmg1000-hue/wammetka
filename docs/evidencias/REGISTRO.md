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

Solo usar `PASS` cuando el resultado haya sido observado. No guardar secretos ni datos personales.
