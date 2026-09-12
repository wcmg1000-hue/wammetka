import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routing/navigator_key.dart';
import 'update_prompt.dart';

/// Chequea `app_config` al arrancar, **después** del splash.
/// `go()` del splash cierra diálogos del navigator raíz si se muestran antes.
class UpdateHost extends StatefulWidget {
  const UpdateHost({super.key, required this.child});

  final Widget child;

  @override
  State<UpdateHost> createState() => _UpdateHostState();
}

class _UpdateHostState extends State<UpdateHost> {
  @override
  void initState() {
    super.initState();
    if (_inWidgetTest) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_run());
    });
  }

  bool get _inWidgetTest {
    return WidgetsBinding.instance.runtimeType.toString().contains(
      'TestWidgetsFlutterBinding',
    );
  }

  Future<void> _run() async {
    for (var i = 0; i < 40; i++) {
      final ctx = wammetkaNavigatorKey.currentContext;
      if (ctx != null && ctx.mounted) {
        final path = GoRouter.maybeOf(ctx)?.state.uri.path ?? '';
        if (path.isNotEmpty && path != '/') {
          await UpdatePrompt.maybeShow(ctx);
          return;
        }
      }
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
