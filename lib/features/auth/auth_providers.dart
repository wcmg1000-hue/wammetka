import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_models.dart';
import 'auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class SessionController extends Notifier<AppProfile?> {
  @override
  AppProfile? build() => null;

  Future<AppProfile?> restore() async {
    final profile = await ref.read(authRepositoryProvider).restoreSession();
    state = profile;
    return profile;
  }

  Future<AppProfile> signIn({
    required String email,
    required String password,
  }) async {
    final profile = await ref
        .read(authRepositoryProvider)
        .signIn(email: email, password: password);
    state = profile;
    return profile;
  }

  Future<AppProfile?> signUpCliente({
    required String email,
    required String password,
    required String nombre,
    required String telefono,
    required String municipioNombre,
  }) async {
    final profile = await ref
        .read(authRepositoryProvider)
        .signUpCliente(
          email: email,
          password: password,
          nombre: nombre,
          telefono: telefono,
          municipioNombre: municipioNombre,
        );
    state = profile;
    return profile;
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = null;
  }
}

final sessionProvider = NotifierProvider<SessionController, AppProfile?>(
  SessionController.new,
);
