import 'package:flutter/material.dart';

import '../../theme/wammetka_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _telefono = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String _municipio = 'Fonseca';
  bool _datos = false;
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

  void _crear() {
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
    setState(() {
      _error = 'Aún no hay servidor. El alta real se conecta en la tarea T03.';
    });
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
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (v) => (v == null || v.trim().length < 2)
                      ? 'Nombre demasiado corto'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _telefono,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                  validator: (v) {
                    final d = (v ?? '').replaceAll(RegExp(r'\D'), '');
                    if (d.length < 7) {
                      return 'Teléfono incompleto';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Correo'),
                  validator: (v) => (v == null || !v.contains('@'))
                      ? 'Correo inválido'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                  validator: (v) => (v == null || v.length < 8)
                      ? 'Mínimo 8 caracteres'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirm,
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
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _municipio = v);
                    }
                  },
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _datos,
                  onChanged: (v) => setState(() => _datos = v ?? false),
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
                  onPressed: _crear,
                  child: const Text('Crear cuenta'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
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
