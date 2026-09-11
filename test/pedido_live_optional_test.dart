import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Live staging. Skipped in CI (no secrets). Local:
/// `flutter test test/pedido_live_optional_test.dart --dart-define-from-file=dart_defines.local.json`
void main() {
  const url = String.fromEnvironment('SUPABASE_URL');
  const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  const seedPassword = String.fromEnvironment('SEED_PASSWORD');

  final live = url.isNotEmpty && anonKey.isNotEmpty && seedPassword.isNotEmpty;

  test(
    'AC-03 crear_pedido total = ítems + domicilio; AC-10 comercio acepta',
    () async {
      if (!live) {
        markTestSkipped('sin dart-define de staging');
        return;
      }
      final client = SupabaseClient(url, anonKey);
      addTearDown(client.dispose);

      await client.auth.signInWithPassword(
        email: 'cliente@wammetka.test',
        password: seedPassword,
      );

      final product = await client
          .from('productos')
          .select('id, precio_centavos, comercio_id')
          .eq('nombre', 'Arroz 500 g')
          .maybeSingle();
      expect(product, isNotNull);
      final comercio = await client
          .from('comercios')
          .select('id, zona_id')
          .eq('id', product!['comercio_id'] as String)
          .single();
      final zona = await client
          .from('zonas')
          .select('id, tarifa_domicilio_centavos')
          .eq('id', comercio['zona_id'] as String)
          .single();

      final raw = await client.rpc(
        'crear_pedido',
        params: <String, dynamic>{
          'p_items': <Map<String, dynamic>>[
            <String, dynamic>{'producto_id': product['id'], 'cantidad': 1},
          ],
          'p_direccion': 'Calle 5 # 10-20 Centro Fonseca',
          'p_zona_id': zona['id'],
        },
      );
      final pedido = Map<String, dynamic>.from(raw as Map);
      final expected =
          (product['precio_centavos'] as int) +
          (zona['tarifa_domicilio_centavos'] as int);
      expect(pedido['estado'], 'pendiente_comercio');
      expect(pedido['total_centavos'], expected);
      expect(pedido['metodo_pago'], 'contraentrega');
      await client.auth.signOut();

      await client.auth.signInWithPassword(
        email: 'comercio@wammetka.test',
        password: seedPassword,
      );
      final seen = await client
          .from('pedidos')
          .select('id, estado, cliente_id')
          .eq('id', pedido['id'] as String)
          .maybeSingle();
      expect(seen, isNotNull);
      expect(seen!['estado'], 'pendiente_comercio');

      final accepted = await client.rpc(
        'responder_pedido',
        params: <String, dynamic>{
          'p_pedido_id': pedido['id'],
          'p_aceptar': true,
          'p_nota': null,
        },
      );
      final acceptedMap = Map<String, dynamic>.from(accepted as Map);
      expect(acceptedMap['estado'], 'aceptado');
      await client.auth.signOut();
    },
  );
}
