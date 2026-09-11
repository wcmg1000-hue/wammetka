# Spec - Módulo de auto-actualización (APK Android)

> **Obligatorio** cuando el proyecto distribuye Android por APK directo (fuera de Google Play).  
> Solo Android. No usar en Play Store. Ver regla `12-auto-update-apk`.  
> Si el proyecto no tiene canal APK directo: no implementar; marcar `N/A` en checklist.

## Objetivo

Mantener la app actualizada automáticamente: al abrir, detectar si hay un `versionCode` más nuevo,
descargar el APK en segundo plano, verificar SHA-256 e instalarlo, sin que el usuario vaya a una tienda.

## Usuarios autorizados

Todos los usuarios de la app (cualquier rol). El chequeo ocurre al iniciar.

## Pantallas / UI

- Aviso de "nueva versión disponible" (diálogo o banner)
- Indicador de progreso de descarga (barra o notificación)
- Botón "Actualizar ahora" / "Más tarde" (si no es forzada)
- Error en español si el hash no coincide (sin instalar)

## Datos de entrada

Según stack en `PROJECT_PROFILE.md`:

**Fuente de verdad:** `versionCode` de Android (`PackageInfo.buildNumber`) vs `app_config.version_code` (Supabase) o Remote Config `version_code` (Firebase).  
El semver `latest_version` es **fallback solo** si `version_code` remoto es null.

**Firebase (D2):** `version_code`, `latest_version`, `apk_url`, `sha256`, `force_update`, `changelog` vía Remote Config; APK en Firebase Storage.

**Supabase (D1):** mismos campos en tabla `app_config`; APK en Storage bucket `apk` (`releases/…`). Publicar con:

```text
flutter build apk --release --target-platform android-arm64
```

o `flutter build apk --release --split-per-abi` (artefacto **arm64**). Ver `docs/PUBLISH_APK.md` y ficha **2.6**.

- Versión instalada (`package_info_plus`: `version` + `buildNumber`)

## Datos de salida

- APK descargado en almacenamiento temporal
- SHA-256 hex minúsculas del archivo
- Lanzamiento del instalador del sistema (`open_filex`) — solo si el hash es OK o se omitió

## Reglas de negocio

- Comparar **`versionCode` / `buildNumber`** como enteros. Semver (major.minor.patch) solo si `version_code` es null.
- Tras descargar: hash SHA-256 hex **minúsculas**. Si el `sha256` remoto **no está vacío** y no coincide → **borrar el archivo, no instalar**, error en español. Si `sha256` está vacío → omitir verificación (filas antiguas).
- Si `force_update` = true, no permitir usar la app hasta actualizar.
- Si Remote Config / `app_config` no responde, continuar con la versión actual (no bloquear).

## Validaciones

- Verificar permiso de instalación de fuentes desconocidas (Android 8+).
- Verificar que la descarga se completó antes de abrir el APK.
- Verificar SHA-256 según regla de negocio arriba.
- Verificar que la plataforma es Android (no-op en iOS).

## Paquetes

`package_info_plus`, `firebase_remote_config` (D2), cliente Supabase (D1), `dio`, `crypto`, `open_filex`, `permission_handler`.

## Casos límite

- Sin internet → mensaje y reintento.
- Descarga interrumpida → borrar parcial y reintentar.
- Permiso denegado → explicar cómo habilitarlo.
- SHA-256 distinto → borrar APK, no instalar, mensaje en español.
- APK con firma distinta → el sistema rechaza; documentar keystore correcta (la misma siempre).

## Criterios de aceptación

- Con un `version_code` mayor publicado, la app lo detecta al abrir.
- Descarga en segundo plano con progreso visible, sin congelar la UI.
- Hash mismatch no instala y borra el archivo.
- Instala correctamente tras conceder permisos (hash OK o vacío).
- En iOS el módulo no se ejecuta. No usar en Google Play.

## Pruebas mínimas

- `versionCode` instalado = remoto → no ofrece actualización.
- `versionCode` instalado < remoto → ofrece y descarga.
- Fallback: `version_code` null y semver 1.9.0 vs 1.10.0 → detecta 1.10.0 como mayor.
- `sha256` remoto no vacío y archivo alterado → no instala.
- Sin conexión → maneja el error sin crashear.

