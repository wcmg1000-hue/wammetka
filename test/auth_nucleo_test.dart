import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:wammetka/features/auth/auth_errors.dart';
import 'package:wammetka/features/auth/auth_models.dart';
import 'package:wammetka/features/auth/auth_policy.dart';
import 'package:wammetka/features/auth/auth_validators.dart';

void main() {
  group('núcleo 1 — auth fallido', () {
    test('AuthException se traduce a mensaje genérico', () {
      const error = AuthException('Invalid login credentials');
      expect(mapAuthFailure(error), kAuthFailedMessage);
    });

    test('error de red no revela si el correo existe', () {
      expect(mapAuthFailure(Exception('SocketException')), kAuthOfflineMessage);
    });
  });

  group('núcleo 2 — rol que no puede', () {
    test('cliente no acepta pedido ni se autoasigna admin', () {
      expect(AuthPolicy.canAcceptPedido(AppRole.cliente), isFalse);
      expect(AuthPolicy.canChangeOwnRole(AppRole.cliente), isFalse);
      expect(AuthPolicy.canSelfRegisterAs(AppRole.comercio), isFalse);
      expect(AuthPolicy.publicRegisterRole, AppRole.cliente);
    });

    test('comercio sí puede aceptar; admin sí puede cambiar rol', () {
      expect(AuthPolicy.canAcceptPedido(AppRole.comercio), isTrue);
      expect(AuthPolicy.canChangeOwnRole(AppRole.admin), isTrue);
      expect(AuthPolicy.canCreatePedido(AppRole.comercio), isFalse);
      expect(AuthPolicy.canReadForeignPedidos(AppRole.cliente), isFalse);
      expect(AuthPolicy.canReadForeignPedidos(AppRole.comercio), isFalse);
    });
  });

  group('núcleo 3 — validación', () {
    test('correo y contraseña obligatorios', () {
      expect(AuthValidators.email(''), isNotNull);
      expect(AuthValidators.email('sin-arroba'), isNotNull);
      expect(AuthValidators.email('cliente@wammetka.test'), isNull);
      expect(AuthValidators.password(''), isNotNull);
      expect(AuthValidators.password('x'), isNull);
      expect(AuthValidators.passwordMin8('corta'), isNotNull);
      expect(AuthValidators.nombre('A'), isNotNull);
      expect(AuthValidators.telefono('12'), isNotNull);
    });
  });
}
