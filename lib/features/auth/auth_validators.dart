abstract final class AuthValidators {
  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty || !v.contains('@') || !v.contains('.')) {
      return 'Escribe un correo válido';
    }
    return null;
  }

  static String? password(String? value) {
    if ((value ?? '').isEmpty) {
      return 'Escribe tu contraseña';
    }
    return null;
  }

  static String? passwordMin8(String? value) {
    if ((value ?? '').length < 8) {
      return 'Mínimo 8 caracteres';
    }
    return null;
  }

  static String? nombre(String? value) {
    if ((value ?? '').trim().length < 2) {
      return 'Nombre demasiado corto';
    }
    return null;
  }

  static String? telefono(String? value) {
    final d = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (d.length < 7) {
      return 'Teléfono incompleto';
    }
    return null;
  }
}
