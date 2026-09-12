import 'update_models.dart';

class UpdateInstaller {
  UpdateInstaller({Object? dio});

  Future<void> downloadAndInstall({
    required AppRemoteConfig config,
    required void Function(double progress) onProgress,
  }) async {}
}
