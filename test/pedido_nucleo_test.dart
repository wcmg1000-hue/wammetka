import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wammetka/features/order/cart_controller.dart';
import 'package:wammetka/features/order/cart_models.dart';
import 'package:wammetka/features/order/money.dart';
import 'package:wammetka/features/order/order_rules.dart';

CartLine _line({
  required String productoId,
  required String comercioId,
  required String comercioNombre,
  int precio = 350000,
  int stock = 20,
  bool abierto = true,
  bool habilitado = true,
}) {
  return CartLine(
    productoId: productoId,
    comercioId: comercioId,
    comercioNombre: comercioNombre,
    nombre: productoId,
    precioCentavos: precio,
    cantidad: 1,
    stock: stock,
    zonaId: 'zona-centro',
    domicilioCentavos: 500000,
    comercioAbierto: abierto,
    municipioHabilitado: habilitado,
  );
}

void main() {
  group('AC-03 — total = ítems + domicilio', () {
    test('Arroz + Gaseosa + domicilio 5.000 COP', () {
      const arroz = 350000;
      const gaseosa = 600000;
      const domicilio = 500000;
      final total = OrderRules.totalCliente(
        subtotalCentavos: arroz + gaseosa,
        domicilioCentavos: domicilio,
      );
      expect(total, 1450000);
      expect(formatCopFromCentavos(total), r'$14.500 COP');
    });
  });

  group('AC-06 — no mezclar comercios', () {
    test('tryAdd de otro comercio devuelve mix y no cambia líneas', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final cart = container.read(cartProvider.notifier);
      expect(
        cart.tryAdd(
          _line(
            productoId: 'arroz',
            comercioId: 'tienda-piloto',
            comercioNombre: 'Tienda Piloto Fonseca',
          ),
        ),
        CartAddResult.added,
      );
      expect(
        cart.tryAdd(
          _line(
            productoId: 'cafe',
            comercioId: 'tienda-vecina',
            comercioNombre: 'Tienda Vecina Fonseca',
            precio: 800000,
          ),
        ),
        CartAddResult.mix,
      );
      expect(container.read(cartProvider).lines, hasLength(1));
      expect(container.read(cartProvider).comercioId, 'tienda-piloto');
    });

    test('replaceWith vacía y agrega del comercio B', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final cart = container.read(cartProvider.notifier);
      cart.tryAdd(
        _line(
          productoId: 'arroz',
          comercioId: 'tienda-piloto',
          comercioNombre: 'Tienda Piloto Fonseca',
        ),
      );
      cart.replaceWith(
        _line(
          productoId: 'cafe',
          comercioId: 'tienda-vecina',
          comercioNombre: 'Tienda Vecina Fonseca',
          precio: 800000,
        ),
      );
      expect(container.read(cartProvider).comercioId, 'tienda-vecina');
      expect(container.read(cartProvider).lines.single.productoId, 'cafe');
    });
  });

  group('AC-07 — stock', () {
    test('cantidad 2 con stock 1 se rechaza', () {
      expect(OrderRules.cantidadVsStock(2, 1), isNotNull);
      expect(OrderRules.cantidadVsStock(1, 1), isNull);
    });

    test('tryAdd no supera stock', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final cart = container.read(cartProvider.notifier);
      final draft = _line(
        productoId: 'unico',
        comercioId: 'tienda-piloto',
        comercioNombre: 'Tienda Piloto Fonseca',
        stock: 1,
      );
      expect(cart.tryAdd(draft), CartAddResult.added);
      expect(cart.tryAdd(draft), CartAddResult.noStock);
      expect(container.read(cartProvider).lines.single.cantidad, 1);
    });
  });

  group('AC-04 / AC-05 / AC-08 — confirmar', () {
    test('comercio cerrado', () {
      expect(
        OrderRules.canConfirm(
          comercioAbierto: false,
          municipioHabilitado: true,
          pedidosEnCurso: 0,
          cantidad: 1,
          stock: 5,
        ),
        'Este comercio no recibe pedidos ahora',
      );
    });

    test('municipio no habilitado', () {
      expect(
        OrderRules.canConfirm(
          comercioAbierto: true,
          municipioHabilitado: false,
          pedidosEnCurso: 0,
          cantidad: 1,
          stock: 5,
        ),
        'Tu municipio no está habilitado',
      );
    });

    test('tope de 3 pedidos en curso', () {
      expect(
        OrderRules.canConfirm(
          comercioAbierto: true,
          municipioHabilitado: true,
          pedidosEnCurso: 3,
          cantidad: 1,
          stock: 5,
        ),
        'Tienes 3 pedidos en curso. Espera o cancela uno',
      );
    });
  });

  group('validación pedido', () {
    test('dirección 10–180', () {
      expect(OrderRules.direccion('corta'), isNotNull);
      expect(OrderRules.direccion('Calle 5 # 10-20 Centro'), isNull);
      expect(OrderRules.direccion('x' * 181), isNotNull);
    });

    test('sameComercio', () {
      expect(OrderRules.sameComercio(null, 'a'), isTrue);
      expect(OrderRules.sameComercio('a', 'a'), isTrue);
      expect(OrderRules.sameComercio('a', 'b'), isFalse);
    });
  });

  group('AC-09 — cancelar pendiente_comercio', () {
    test('cliente puede cancelar solo si espera al comercio', () {
      expect(OrderRules.canCancelCliente('pendiente_comercio'), isTrue);
      expect(OrderRules.canCancelCliente('aceptado'), isFalse);
      expect(OrderRules.canCancelCliente('preparado'), isFalse);
      expect(OrderRules.canCancelCliente('entregado'), isFalse);
    });
  });
}
