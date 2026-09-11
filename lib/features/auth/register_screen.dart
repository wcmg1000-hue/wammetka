import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../routing/role_home.dart';
import '../../theme/wammetka_colors.dart';
import 'auth_errors.dart';
import 'auth_providers.dart';
import 'auth_validators.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _telefono = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String _municipio = 'Fonseca';
  bool _datos = false;
  bool _busy = false;
  String? _error;

  static const List<String> _municipios = <String>[
    'Albania',
    'Hatonuevo',
    'Barrancas',
    'Fonseca',
    'Distracción',
    'San Juan del Cesar',
  ];

  @override
  void dispose() {
    _nombre.dispose();
    _telefono.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _crear() async {
    setState(() => _error = null);
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (!_datos) {
      setState(() {
        _error = 'Debes aceptar el aviso de tratamiento de datos';
      });
      return;
    }
    setState(() => _busy = true);
    final router = GoRouter.of(context);
    try {
      final profile = await ref
          .read(sessionProvider.notifier)
          .signUpCliente(
            email: _email.text,
            password: _password.text,
            nombre: _nombre.text,
            telefono: _telefono.text,
            municipioNombre: _municipio,
          );
      if (!mounted) {
        return;
      }
      if (profile == null) {
        setState(() {
          _error = 'Cuenta creada. Si pide confirmación, revisa el correo y luego entra.';
        });
        return;
      }
      router.go(homePathFor(profile.rol));
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _error = mapAuthFailure(error));
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nombre,
                  enabled: !_busy,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: AuthValidators.nombre,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _telefono,
                  enabled: !_busy,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                  validator: AuthValidators.telefono,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _email,
                  enabled: !_busy,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Correo'),
                  validator: AuthValidators.email,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _password,
                  enabled: !_busy,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                  validator: AuthValidators.passwordMin8,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirm,
                  enabled: !_busy,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar contraseña',
                  ),
                  validator: (v) => v != _password.text
                      ? 'Las contraseñas no coinciden'
                      : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _municipio,
                  decoration: const InputDecoration(labelText: 'Municipio'),
                  items: [
                    for (final m in _municipios)
                      DropdownMenuItem<String>(value: m, child: Text(m)),
                  ],
                  onChanged: _busy
                      ? null
                      : (v) {
                          if (v != null) {
                            setState(() => _municipio = v);
                          }
                        },
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _datos,
                  onChanged: _busy
                      ? null
                      : (v) => setState(() => _datos = v ?? false),
                  title: const Text(
                    'Acepto el aviso de tratamiento de datos',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                if (_error != null)
                  Text(_error!, style: TextStyle(color: WammetkaColors.error)),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _busy ? null : _crear,
                  child: _busy
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Crear cuenta'),
                ),
                TextButton(
                  onPressed: _busy ? null : () => context.go('/login'),
                  child: const Text('Volver a Entrar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
