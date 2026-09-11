import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_bootstrap.dart';
import '../order/order_errors.dart';
import 'catalog_models.dart';

class CatalogRepository {
  CatalogRepository([SupabaseClient? client])
    : _client = client ?? SupabaseHolder.client;

  final SupabaseClient? _client;

  Future<List<Municipio>> listMunicipiosHabilitados() async {
    final client = _requireClient();
    try {
      final rows = await client
          .from('municipios')
          .select('id, nombre, habilitado')
          .eq('habilitado', true)
          .order('nombre')
          .limit(50);
      return (rows as List<dynamic>)
          .map(
            (row) => Municipio.fromMap(Map<String, dynamic>.from(row as Map)),
          )
          .toList();
    } catch (error) {
      throw OrderAppException(mapOrderFailure(error));
    }
  }

  Future<Municipio?> getMunicipio(String id) async {
    final client = _requireClient();
    try {
      final row = await client
          .from('municipios')
          .select('id, nombre, habilitado')
          .eq('id', id)
          .maybeSingle();
      if (row == null) {
        return null;
      }
      return Municipio.fromMap(row);
    } catch (error) {
      throw OrderAppException(mapOrderFailure(error));
    }
  }

  Future<List<Comercio>> listComercios({required String municipioId}) async {
    final client = _requireClient();
    try {
      final rows = await client
          .from('comercios')
          .select(
            'id, nombre, abierto, hora_apertura, hora_cierre, telefono, municipio_id, zona_id, estado_aprobacion',
          )
          .eq('municipio_id', municipioId)
          .eq('estado_aprobacion', 'activo')
          .order('nombre')
          .limit(50);
      final list = (rows as List<dynamic>)
          .map((row) => Map<String, dynamic>.from(row as Map))
          .toList();
      return await _hydrateComercios(client, list);
    } catch (error) {
      throw OrderAppException(mapOrderFailure(error));
    }
  }

  Future<Comercio?> getComercio(String id) async {
    final client = _requireClient();
    try {
      final row = await client
          .from('comercios')
          .select(
            'id, nombre, abierto, hora_apertura, hora_cierre, telefono, municipio_id, zona_id, estado_aprobacion',
          )
          .eq('id', id)
          .maybeSingle();
      if (row == null) {
        return null;
      }
      final hydrated = await _hydrateComercios(client, <Map<String, dynamic>>[
        row,
      ]);
      return hydrated.isEmpty ? null : hydrated.first;
    } catch (error) {
      throw OrderAppException(mapOrderFailure(error));
    }
  }

  Future<List<Producto>> listProductos({
    required String comercioId,
    required bool soloDisponibles,
  }) async {
    final client = _requireClient();
    try {
      var query = client
          .from('productos')
          .select(
            'id, comercio_id, nombre, sku, precio_centavos, stock, disponible',
          )
          .eq('comercio_id', comercioId)
          .isFilter('deleted_at', null);
      if (soloDisponibles) {
        query = query.eq('disponible', true);
      }
      final rows = await query.order('nombre').limit(50);
      return (rows as List<dynamic>)
          .map((row) => Producto.fromMap(Map<String, dynamic>.from(row as Map)))
          .toList();
    } catch (error) {
      throw OrderAppException(mapOrderFailure(error));
    }
  }

  Future<void> setComercioAbierto({
    required String comercioId,
    required bool abierto,
  }) async {
    final client = _requireClient();
    try {
      await client
          .from('comercios')
          .update(<String, dynamic>{'abierto': abierto})
          .eq('id', comercioId);
    } catch (error) {
      throw OrderAppException(mapOrderFailure(error));
    }
  }

  Future<void> setProductoDisponible({
    required String productoId,
    required bool disponible,
  }) async {
    final client = _requireClient();
    try {
      await client
          .from('productos')
          .update(<String, dynamic>{'disponible': disponible})
          .eq('id', productoId);
    } catch (error) {
      throw OrderAppException(mapOrderFailure(error));
    }
  }

  Future<void> upsertProducto({
    String? id,
    required String comercioId,
    required String nombre,
    required int precioCentavos,
    required int stock,
    String? sku,
  }) async {
    final client = _requireClient();
    try {
      final payload = <String, dynamic>{
        'comercio_id': comercioId,
        'nombre': nombre.trim(),
        'precio_centavos': precioCentavos,
        'stock': stock,
        'disponible': true,
        if (sku != null && sku.trim().isNotEmpty) 'sku': sku.trim(),
      };
      if (id == null) {
        await client.from('productos').insert(payload);
      } else {
        await client.from('productos').update(payload).eq('id', id);
      }
    } catch (error) {
      throw OrderAppException(mapOrderFailure(error));
    }
  }

  Future<void> updateOwnMunicipio(String municipioId) async {
    final client = _requireClient();
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      throw const OrderAppException('Debes iniciar sesión');
    }
    try {
      await client
          .from('profiles')
          .update(<String, dynamic>{'municipio_id': municipioId})
          .eq('id', userId);
    } catch (error) {
      throw OrderAppException(mapOrderFailure(error));
    }
  }

  Future<List<Comercio>> _hydrateComercios(
    SupabaseClient client,
    List<Map<String, dynamic>> rows,
  ) async {
    if (rows.isEmpty) {
      return <Comercio>[];
    }
    final zonaIds = rows
        .map((row) => row['zona_id'] as String)
        .toSet()
        .toList();
    final munIds = rows
        .map((row) => row['municipio_id'] as String)
        .toSet()
        .toList();
    final zonas = await client
        .from('zonas')
        .select('id, nombre, tarifa_domicilio_centavos')
        .inFilter('id', zonaIds);
    final muns = await client
        .from('municipios')
        .select('id, nombre, habilitado')
        .inFilter('id', munIds);
    final zonaById = <String, Map<String, dynamic>>{
      for (final row in zonas as List<dynamic>)
        (row as Map)['id'] as String: Map<String, dynamic>.from(row),
    };
    final munById = <String, Map<String, dynamic>>{
      for (final row in muns as List<dynamic>)
        (row as Map)['id'] as String: Map<String, dynamic>.from(row),
    };
    return rows
        .map(
          (row) => Comercio.fromMaps(
            comercio: row,
            zona: zonaById[row['zona_id'] as String],
            municipio: munById[row['municipio_id'] as String],
          ),
        )
        .toList();
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
