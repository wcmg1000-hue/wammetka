# Publicar APK (CD opcional)

Tras CI **verde** en el remoto del perfil, se puede publicar el APK **arm64** para auto-update. No sustituye la prueba en el teléfono. **No pongas secretos** en YAML, scripts de ejemplo ni en este archivo.

Detalle de campos: `docs/specs/MODULO_ACTUALIZACION.md`. Ficha práctica: lecciones **2.6**.

## Artefacto

```text
flutter build apk --release --target-platform android-arm64
```

Alternativa: `flutter build apk --release --split-per-abi` y conservar `app-arm64-v8a-release.apk`.

Calcular **SHA-256 hex en minúsculas** del archivo. El `versionCode` (entero de Android / `PackageInfo.buildNumber`) va a `version_code`.

## Pasos (sin secretos)

1. CI verde (format + analyze + test + build arm64 en la rama default).
2. Subir el APK al bucket (`apk/releases/…`) — Storage de Supabase o Firebase según stack.
3. PATCH / Remote Config:
   - `latest_version` (semver, informativo)
   - `version_code` (entero; fuente de verdad)
   - `sha256` (hex minúsculas; vacío solo si se omite verificación, filas antiguas)
   - `apk_url`, `force_update`, `changelog`
4. Script de referencia: `scripts/upload_apk.ps1`. Auth seed admin (no `service_role` en la app). Sube a `apk/releases/…` y hace `PATCH` de `app_config` (`latest_version`, `version_code`, `sha256`, `apk_url`, `force_update`, `changelog`). Claves solo en `.env` local o secretos de CI.

## GitLab

Job de ejemplo **comentado** en `.gitlab-ci.yml.example`: `publish_apk` con `when: manual`, después de `build_apk`. Activarlo copiando el bloque al `.gitlab-ci.yml` del repo. Secretos: **Settings → CI/CD → Variables**.

## GitHub Actions

Stub comentado / `workflow_dispatch` en `.github/workflows/ci.yml`. Misma intención: invocar `scripts/upload_apk.ps1` (o equivalente) **a mano** tras el build verde. Secretos: **Settings → Secrets and variables → Actions**.

## Evidencia

Fila en `docs/evidencias/REGISTRO.md`: pipeline, `version_code`, hash (no la keystore). Probar auto-update en el teléfono.

