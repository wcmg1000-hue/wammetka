import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../theme/wammetka_colors.dart';
import 'update_installer.dart';
import 'update_models.dart';
import 'update_repository.dart';
import 'update_rules.dart';

abstract final class UpdatePrompt {
  static final _repo = UpdateRepository();
  static final _installer = UpdateInstaller();

  static Future<void> maybeShow(
    BuildContext context, {
    bool fromUser = false,
  }) async {
    if (kIsWeb ||
        defaultTargetPlatform != TargetPlatform.android ||
        const bool.fromEnvironment('FLUTTER_TEST')) {
      return;
    }
    try {
      final info = await PackageInfo.fromPlatform();
      final localBuild = int.tryParse(info.buildNumber) ?? 0;
      final config = await _repo.fetchConfig();
      if (!context.mounted) {
        return;
      }
      if (config == null) {
        if (fromUser) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text(kUpdateOfflineMessage)));
        }
        return;
      }
      final offer = UpdateRules.shouldOfferUpdate(
        localBuildNumber: localBuild,
        remoteVersionCode: config.versionCode,
        localSemver: info.version,
        remoteSemver: config.latestVersion,
      );
      if (!offer || (config.apkUrl ?? '').isEmpty) {
        if (fromUser) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Esta versión está al día (código $localBuild).',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }
        return;
      }
      await showDialog<void>(
        context: context,
        barrierDismissible: !config.forceUpdate,
        builder: (ctx) => UpdateDialog(config: config, installer: _installer),
      );
    } catch (_) {
      if (fromUser && context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text(kUpdateOfflineMessage)));
      }
    }
  }
}

class UpdateDialog extends StatefulWidget {
  const UpdateDialog({
    super.key,
    required this.config,
    required this.installer,
  });

  final AppRemoteConfig config;
  final UpdateInstaller installer;

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool _busy = false;
  double _progress = 0;
  String? _error;

  Future<void> _actualizar() async {
    setState(() {
      _busy = true;
      _error = null;
      _progress = 0;
    });
    try {
      await widget.installer.downloadAndInstall(
        config: widget.config,
        onProgress: (value) {
          if (mounted) {
            setState(() => _progress = value);
          }
        },
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error.toString();
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final notes = widget.config.changelog?.trim();
    return AlertDialog(
      title: const Text(
        'Nueva versión disponible',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            notes == null || notes.isEmpty
                ? 'Hay una versión nueva de Wammetka. Se descarga en segundo plano.'
                : notes,
            maxLines: 6,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium,
          ),
          if (_busy) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(value: _progress <= 0 ? null : _progress),
            const SizedBox(height: 8),
            Text(
              _progress <= 0
                  ? 'Descargando…'
                  : '${(_progress * 100).clamp(0, 100).toStringAsFixed(0)} %',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyMedium?.copyWith(
                color: WammetkaColors.error,
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (!widget.config.forceUpdate && !_busy)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Más tarde'),
          ),
        FilledButton(
          onPressed: _busy ? null : _actualizar,
          child: const Text('Actualizar ahora'),
        ),
      ],
    );
  }
}
