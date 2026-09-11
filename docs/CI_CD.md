# CI/CD — GitHub Actions o GitLab CI

La CI es **obligatoria** en el **remoto del perfil**: marcar **uno** en `PROJECT_PROFILE.md` (GitHub **o** GitLab). Plugin GitHub y/o GitLab en Cursor según esa elección.

## ¿Qué es CI y qué es CD?

| | **CI — Integración continua** | **CD — Entrega / despliegue continuo** |
|---|---|---|
| Qué hace | En PR/MR y rama default: format + analyze + test; en default también build | Tras CI verde, publica/despliega (APK a Storage, hosting, etc.) |
| Pregunta que responde | ¿Este cambio rompe algo? | ¿Lo pongo ya en staging/producción? |
| ¿Menos errores? | **Sí** — atrapa regresiones antes del dispositivo | Solo si el deploy está bien diseñado |
| ¿Más velocidad? | **Sí a medio plazo** | No sustituye smoke en dispositivo del perfil |
| En Código Germinación | **Obligatoria siempre** (en el remoto elegido) | **Opcional** y con aprobación |

**Política de jobs (mejor opción del kit):**

| Job | PR / MR | Rama default (`main`) |
|---|---|---|
| `format` | sí | sí |
| `analyze` | sí | sí |
| `test` (núcleo) | sí | sí |
| `build` (APK arm64 / web) | **no** | sí |
| `publish_apk` (CD) | no | **manual** / `workflow_dispatch` |
| `rules` / RLS | **no** en YAML base | opcional por stack (ver abajo) |

## Política (obligatoria)

1. Desde **T02** (tras scaffold): copiar el esqueleto del remoto elegido, alineado con `VERIFICACION.md`.
   - GitLab → `.gitlab-ci.yml` desde `.gitlab-ci.yml.example`
   - GitHub → `.github/workflows/ci.yml` (ejemplo Flutter en el molde)
2. Remoto = **GitHub o GitLab** (uno). Plugin en Cursor según elección, para pipelines/PR/MR.
3. Misma política de jobs en demo y proyecto completo.
4. No marcar PASS de rebanada si el pipeline está rojo (salvo excepción: riesgo, responsable, fecha).
5. DoD de T02: pipeline **PASS** en el remoto elegido.

## Jobs mínimos

Fuente de verdad del esqueleto: **`.gitlab-ci.yml.example`** y **`.github/workflows/ci.yml`**. Resumen Flutter:

```yaml
# verify (PR/MR + default)
format:  dart format --set-exit-if-changed .
analyze: flutter analyze
test:    flutter test

# build solo default
build_apk: flutter build apk --release --target-platform android-arm64
# alternativa: --split-per-abi y conservar el artefacto arm64
```

Copiar comandos definitivos a `VERIFICACION.md`. Secretos solo en **variables CI** del remoto (GitHub Secrets o GitLab CI/CD Variables).

## Rules / RLS en CI (opcional, no en el YAML base)

Se prueban en **Fase 2D local** (emulador / Supabase local).  
Un job CI de rules solo si el proyecto ya tiene runner con emulador/CLI y lo documenta en `VERIFICACION.md` — **no** es puerta del molde.

## CD (opcional)

| Acción CD | Cuándo | Plantilla 2.12 |
|---|---|---|
| Subir APK arm64 a Storage + `app_config` / Remote Config (`version`, `version_code`, `sha256`, `apk_url`) | Tras CI verde + **aprobación manual** | GitLab: job `publish_apk` `when: manual` (comentado en `.gitlab-ci.yml.example`). GitHub: stub `workflow_dispatch` en `.github/workflows/ci.yml`. Pasos: `docs/PUBLISH_APK.md` → `scripts/upload_apk.ps1` |
| Deploy hosting web | Si hay target web | según stack |
| Producción | Solo aprobación explícita (Fase 6) | — |

Auto-update en el teléfono ≠ CD del repo.

## Matriz orientativa

| Stack | CI base (kit) | Opcional |
|---|---|---|
| Flutter Android | format · analyze · test · build apk **arm64** (solo default) | `publish_apk` manual |
| Flutter web | format · analyze · test · `build web` (solo default) | — |
| Supabase | — | `db lint` / tests RLS si hay runner |
| Firebase | — | rules tests si hay Emulator en runner |

## Evidencia

`docs/evidencias/REGISTRO.md`: URL del pipeline, commit, pass/fail.

