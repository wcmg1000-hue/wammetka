import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'update_models.dart';
import 'update_rules.dart';

class UpdateInstaller {
  UpdateInstaller({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  Future<void> downloadAndInstall({
    required AppRemoteConfig config,
    required void Function(double progress) onProgress,
  }) async {
    final url = config.apkUrl?.trim() ?? '';
    if (url.isEmpty) {
      throw const UpdateException(kUpdateOfflineMessage);
    }
    if (!Platform.isAndroid) {
      return;
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/wammetka-update.apk');
    if (file.existsSync()) {
      await file.delete();
    }

    try {
      await _dio.download(
        url,
        file.path,
        options: Options(
          receiveTimeout: const Duration(minutes: 15),
          sendTimeout: const Duration(minutes: 2),
        ),
        onReceiveProgress: (received, total) {
          if (total > 0) {
            onProgress(received / total);
          }
        },
      );
    } on DioException {
      if (file.existsSync()) {
        await file.delete();
      }
      throw const UpdateException(kUpdateOfflineMessage);
    }

    if (!file.existsSync() || file.lengthSync() < 1024) {
      if (file.existsSync()) {
        await file.delete();
      }
      throw const UpdateException(kUpdateOfflineMessage);
    }

    final digest = sha256.convert(await file.readAsBytes());
    final hex = digest.toString();
    if (!UpdateRules.hashMatches(
      remoteSha: config.sha256,
      fileShaHexLower: hex,
    )) {
      await file.delete();
      throw const UpdateException(kUpdateHashMismatchMessage);
    }

    final status = await Permission.requestInstallPackages.request();
    if (!status.isGranted) {
      throw const UpdateException(kUpdatePermissionMessage);
    }

    final result = await OpenFilex.open(
      file.path,
      type: 'application/vnd.android.package-archive',
    );
    if (result.type != ResultType.done) {
      throw UpdateException(
        result.message.isEmpty
            ? kUpdatePermissionMessage
            : 'No se pudo abrir el instalador. ${result.message}',
      );
    }
  }
}
