import 'package:flutter_test/flutter_test.dart';

import 'package:wammetka/features/auth/auth_models.dart';
import 'package:wammetka/features/auth/auth_policy.dart';
import 'package:wammetka/features/order/order_rules.dart';

void main() {
  group('transiciones despacho', () {
    test('oferta aceptado/preparado sin repartidor', () {
      expect(DispatchRules.isOferta('preparado', null), isTrue);
      expect(DispatchRules.isOferta('aceptado', null), isTrue);
      expect(DispatchRules.isOferta('preparado', 'rep-1'), isFalse);
      expect(DispatchRules.isOferta('asignado', null), isFalse);
    });

    test('repartidor acepta → puede marcar recogido → entregado', () {
      expect(
        DispatchRules.canAcceptServicio(
          rol: 'repartidor',
          estado: 'preparado',
          repartidorId: null,
        ),
        isTrue,
      );
      expect(
        DispatchRules.canMarkRecogido(
          rol: 'repartidor',
          estado: 'asignado',
          actorId: 'rep-1',
          repartidorId: 'rep-1',
        ),
        isTrue,
      );
      expect(
        DispatchRules.canMarkEntregado(
          rol: 'repartidor',
          estado: 'recogido',
          actorId: 'rep-1',
          repartidorId: 'rep-1',
        ),
        isTrue,
      );
    });

    test('nota de entrega obligatoria', () {
      expect(DispatchRules.entregaNota(''), isNotNull);
      expect(DispatchRules.entregaNota('ok'), isNotNull);
      expect(DispatchRules.entregaNota('En portería'), isNull);
    });
  });

  group('no-puede', () {
    test('cliente no marca entregado ni acepta servicio', () {
      expect(AuthPolicy.canMarkEntregado(AppRole.cliente), isFalse);
      expect(AuthPolicy.canAcceptServicio(AppRole.cliente), isFalse);
      expect(AuthPolicy.canAcceptServicio(AppRole.repartidor), isTrue);
      expect(
        DispatchRules.canMarkEntregado(
          rol: 'cliente',
          estado: 'recogido',
          actorId: 'cli-1',
          repartidorId: 'rep-1',
        ),
        isFalse,
      );
    });

    test('repartidor no ve comisión Wammetka', () {
      expect(AuthPolicy.canSeeComisionWammetka(AppRole.repartidor), isFalse);
      expect(AuthPolicy.canSeeComisionWammetka(AppRole.cliente), isFalse);
      expect(AuthPolicy.canSeeComisionWammetka(AppRole.admin), isTrue);
    });
  });
}
