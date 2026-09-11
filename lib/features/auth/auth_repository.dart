import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_bootstrap.dart';
import 'auth_errors.dart';
import 'auth_models.dart';
import 'auth_policy.dart';

class AuthRepository {
  AuthRepository([SupabaseClient? client])
    : _client = client ?? SupabaseHolder.client;

  final SupabaseClient? _client;

  bool get isReady => _client != null;

  Future<AppProfile?> restoreSession() async {
    final client = _client;
    if (client == null) {
      return null;
    }
    try {
      final session = client.auth.currentSession;
      final userId = session?.user.id;
      if (userId == null) {
        return null;
      }
      return await _loadProfile(client, userId);
    } on AuthAppException {
      rethrow;
    } catch (_) {
      return null;
    }
  }

  Future<AppProfile> signIn({
    required String email,
    required String password,
  }) async {
    final client = _client;
    if (client == null) {
      throw const AuthAppException(kAuthMissingConfigMessage);
    }
    try {
      final res = await client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      final userId = res.user?.id;
      if (userId == null) {
        throw const AuthAppException(kAuthFailedMessage);
      }
      return await _loadProfile(client, userId);
    } on AuthAppException {
      rethrow;
    } on AuthException {
      throw const AuthAppException(kAuthFailedMessage);
    } catch (_) {
      throw const AuthAppException(kAuthOfflineMessage);
    }
  }

  Future<AppProfile?> signUpCliente({
    required String email,
    required String password,
    required String nombre,
    required String telefono,
    required String municipioNombre,
  }) async {
    final client = _client;
    if (client == null) {
      throw const AuthAppException(kAuthMissingConfigMessage);
    }
    if (!AuthPolicy.canSelfRegisterAs(AuthPolicy.publicRegisterRole)) {
      throw const AuthAppException('El registro público solo crea clientes.');
    }
    try {
      final res = await client.auth.signUp(
        email: email.trim(),
        password: password,
        data: <String, dynamic>{'nombre': nombre.trim(), 'telefono': telefono},
      );
      final userId = res.user?.id;
      if (userId == null) {
        return null;
      }
      if (res.session == null) {
        return null;
      }
      await _attachMunicipio(
        client,
        userId: userId,
        municipioNombre: municipioNombre,
        nombre: nombre.trim(),
        telefono: telefono,
      );
      return await _loadProfile(client, userId);
    } on AuthAppException {
      rethrow;
    } on AuthException {
      throw const AuthAppException(kAuthFailedMessage);
    } catch (_) {
      throw const AuthAppException(kAuthOfflineMessage);
    }
  }

  Future<void> signOut() async {
    final client = _client;
    if (client == null) {
      return;
    }
    await client.auth.signOut();
  }

  Future<AppProfile> syncOwnProfile() async {
    final client = _client;
    if (client == null) {
      throw const AuthAppException(kAuthMissingConfigMessage);
    }
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthAppException(kAuthFailedMessage);
    }
    try {
      await client
          .from('profiles')
          .update(<String, dynamic>{'telefono': '3001234567'})
          .eq('id', userId);
      return await _loadProfile(client, userId);
    } on AuthAppException {
      rethrow;
    } catch (_) {
      throw const AuthAppException(kAuthOfflineMessage);
    }
  }

  Future<AppProfile> _loadProfile(SupabaseClient client, String userId) async {
    final row = await client
        .from('profiles')
        .select('id, rol, nombre, activo, telefono, municipio_id, comercio_id')
        .eq('id', userId)
        .maybeSingle();
    if (row == null) {
      await client.auth.signOut();
      throw const AuthAppException(kAuthOrphanProfileMessage);
    }
    final profile = AppProfile.fromMap(row);
    if (!profile.activo) {
      await client.auth.signOut();
      throw const AuthAppException(kAuthDisabledMessage);
    }
    return profile;
  }

  Future<void> _attachMunicipio(
    SupabaseClient client, {
    required String userId,
    required String municipioNombre,
    required String nombre,
    required String telefono,
  }) async {
    final mun = await client
        .from('municipios')
        .select('id')
        .eq('nombre', municipioNombre)
        .maybeSingle();
    await client
        .from('profiles')
        .update(<String, dynamic>{
          'nombre': nombre,
          'telefono': telefono,
          if (mun != null) 'municipio_id': mun['id'],
        })
        .eq('id', userId);
  }
}
