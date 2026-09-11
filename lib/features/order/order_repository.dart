import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_bootstrap.dart';
import 'cart_models.dart';
import 'order_errors.dart';
import 'order_models.dart';
import 'order_rules.dart';

class OrderRepository {
  OrderRepository([SupabaseClient? client])
    : _client = client ?? SupabaseHolder.client;

  final SupabaseClient? _client;

  Future<Pedido> crearPedido({
    required CartState cart,
    required String direccion,
    required bool comercioAbierto,
    required bool municipioHabilitado,
    required int pedidosEnCurso,
  }) async {
    final addr = OrderRules.direccion(direccion);
    if (addr != null) {
      throw OrderAppException(addr);
    }
    if (cart.isEmpty) {
      throw const OrderAppException('El carrito está vacío');
    }
    for (final line in cart.lines) {
      final stockErr = OrderRules.cantidadVsStock(line.cantidad, line.stock);
      if (stockErr != null) {
        throw OrderAppException(stockErr);
      }
    }
    final blocked = OrderRules.canConfirm(
      comercioAbierto: comercioAbierto,
      municipioHabilitado: municipioHabilitado,
      pedidosEnCurso: pedidosEnCurso,
      cantidad: cart.lines.first.cantidad,
      stock: cart.lines.first.stock,
    );
    if (blocked != null) {
      throw OrderAppException(blocked);
    }

    final client = _requireClient();
    try {
      final raw = await client
          .rpc(
            'crear_pedido',
            params: <String, dynamic>{
              'p_items': cart.toRpcItems(),
              'p_direccion': direccion.trim(),
              'p_zona_id': cart.zonaId,
            },
          )
          .timeout(const Duration(seconds: 20));
      return Pedido.fromMap(asPedidoMap(raw));
    } on TimeoutException {
      throw const OrderAppException(kOrderOfflineMessage);
    } on OrderShapeException {
      throw const OrderAppException('No se pudo crear el pedido');
    } catch (error) {
      throw OrderAppException(mapOrderFailure(error));
    }
  }

  Future<int> countEnCurso() async {
    final client = _requireClient();
    try {
      final rows = await client.from('pedidos').select('id, estado').limit(50);
      return (rows as List<dynamic>).where((row) {
        final estado = (row as Map)['estado'] as String? ?? '';
        return pedidoEsActivo(estado);
      }).length;
    } catch (error) {
      throw OrderAppException(mapOrderFailure(error));
    }
  }

  Future<List<Pedido>> listMine() async {
    return _listPedidos();
  }

  Future<Pedido?> getById(String id) async {
    final list = await _listPedidos(id: id);
    return list.isEmpty ? null : list.first;
  }

  Future<Pedido> responder({
    required String pedidoId,
    required bool aceptar,
    String? nota,
  }) async {
    final client = _requireClient();
    try {
      final raw = await client
          .rpc(
            'responder_pedido',
            params: <String, dynamic>{
              'p_pedido_id': pedidoId,
              'p_aceptar': aceptar,
              'p_nota': nota,
            },
          )
          .timeout(const Duration(seconds: 20));
      return Pedido.fromMap(asPedidoMap(raw));
    } on TimeoutException {
      throw const OrderAppException(kOrderOfflineMessage);
    } catch (error) {
      throw OrderAppException(mapOrderFailure(error));
    }
  }

  Future<Pedido> cancelar(String pedidoId) async {
    final client = _requireClient();
    try {
      final raw = await client
          .rpc(
            'cancelar_pedido',
            params: <String, dynamic>{'p_pedido_id': pedidoId},
          )
          .timeout(const Duration(seconds: 20));
      return Pedido.fromMap(asPedidoMap(raw));
    } on TimeoutException {
      throw const OrderAppException(kOrderOfflineMessage);
    } catch (error) {
      throw OrderAppException(mapOrderFailure(error));
    }
  }

  Future<Pedido> marcarPreparado(String pedidoId) async {
    final client = _requireClient();
    try {
      final raw = await client
          .rpc(
            'marcar_pedido_preparado',
            params: <String, dynamic>{'p_pedido_id': pedidoId},
          )
          .timeout(const Duration(seconds: 20));
      return Pedido.fromMap(asPedidoMap(raw));
    } on TimeoutException {
      throw const OrderAppException(kOrderOfflineMessage);
    } catch (error) {
      throw OrderAppException(mapOrderFailure(error));
    }
  }

  Future<List<Pedido>> _listPedidos({String? id}) async {
    final client = _requireClient();
    try {
      var query = client
          .from('pedidos')
          .select(
            'id, cliente_id, comercio_id, zona_id, estado, metodo_pago, subtotal_centavos, domicilio_centavos, total_centavos, direccion_texto, created_at, pedido_items(nombre_snapshot, precio_centavos, cantidad, subtotal_centavos)',
          );
      if (id != null) {
        query = query.eq('id', id);
      }
      final rows = await query.order('created_at', ascending: false).limit(50);
      final pedidos = (rows as List<dynamic>)
          .map((row) => Pedido.fromMap(Map<String, dynamic>.from(row as Map)))
          .toList();
      if (pedidos.isEmpty) {
        return pedidos;
      }
      final comercioIds = pedidos.map((p) => p.comercioId).toSet().toList();
      final clienteIds = pedidos.map((p) => p.clienteId).toSet().toList();
      final shops = await client
          .from('comercios')
          .select('id, nombre, telefono')
          .inFilter('id', comercioIds);
      final shopById = <String, Map<String, dynamic>>{
        for (final row in shops as List<dynamic>)
          (row as Map)['id'] as String: Map<String, dynamic>.from(row),
      };
      Map<String, Map<String, dynamic>> peopleById =
          <String, Map<String, dynamic>>{};
      try {
        final people = await client
            .from('profiles')
            .select('id, nombre, telefono')
            .inFilter('id', clienteIds);
        peopleById = <String, Map<String, dynamic>>{
          for (final row in people as List<dynamic>)
            (row as Map)['id'] as String: Map<String, dynamic>.from(row),
        };
      } catch (_) {
        peopleById = <String, Map<String, dynamic>>{};
      }
      return pedidos.map((pedido) {
        final shop = shopById[pedido.comercioId];
        final person = peopleById[pedido.clienteId];
        return pedido.copyWith(
          comercioNombre: shop?['nombre'] as String?,
          comercioTelefono: shop?['telefono'] as String?,
          clienteNombre: person?['nombre'] as String?,
          clienteTelefono: person?['telefono'] as String?,
        );
      }).toList();
    } catch (error) {
      throw OrderAppException(mapOrderFailure(error));
    }
  }

  SupabaseClient _requireClient() {
    final client = _client;
    if (client == null) {
      throw const OrderAppException(
        'Falta configuración del servidor. Compila con SUPABASE_ANON_KEY.',
      );
    }
    return client;
  }
}
