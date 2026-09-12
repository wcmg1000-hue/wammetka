class AppRemoteConfig {
  const AppRemoteConfig({
    required this.versionCode,
    required this.latestVersion,
    required this.apkUrl,
    required this.sha256,
    required this.forceUpdate,
    this.changelog,
  });

  final int? versionCode;
  final String? latestVersion;
  final String? apkUrl;
  final String sha256;
  final bool forceUpdate;
  final String? changelog;

  factory AppRemoteConfig.fromMap(Map<String, dynamic> map) {
    final rawCode = map['version_code'];
    int? code;
    if (rawCode is int) {
      code = rawCode;
    } else if (rawCode is num) {
      code = rawCode.toInt();
    }
    return AppRemoteConfig(
      versionCode: code,
      latestVersion: map['latest_version'] as String?,
      apkUrl: map['apk_url'] as String?,
      sha256: (map['sha256'] as String?) ?? '',
      forceUpdate: map['force_update'] as bool? ?? false,
      changelog: map['changelog'] as String?,
    );
  }
}

class UpdateOffer {
  const UpdateOffer({
    required this.config,
    required this.localBuild,
    required this.localSemver,
  });

  final AppRemoteConfig config;
  final int localBuild;
  final String localSemver;
}

const kUpdateHashMismatchMessage =
    'El archivo descargado no es válido. No se instaló. Intenta de nuevo.';
const kUpdateOfflineMessage =
    'No hay red. Sigue con esta versión e inténtalo más tarde.';
const kUpdatePermissionMessage =
    'Activa el permiso para instalar apps de esta fuente en Ajustes.';

class UpdateException implements Exception {
  const UpdateException(this.message);

  final String message;

  @override
  String toString() => message;
}
