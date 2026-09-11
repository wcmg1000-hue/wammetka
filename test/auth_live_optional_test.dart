import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Live staging. Skipped in CI (no secrets). Local:
/// `flutter test test/auth_live_optional_test.dart --dart-define-from-file=dart_defines.local.json`
void main() {
  const url = String.fromEnvironment('SUPABASE_URL');
  const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  const seedPassword = String.fromEnvironment('SEED_PASSWORD');

  final live = url.isNotEmpty && anonKey.isNotEmpty && seedPassword.isNotEmpty;

  test('login seed cliente@wammetka.test y no-puede autoascenso', () async {
    if (!live) {
      markTestSkipped('sin dart-define de staging');
      return;
    }
    final client = SupabaseClient(url, anonKey);
    addTearDown(client.dispose);

    try {
      await client.auth.signInWithPassword(
        email: 'cliente@wammetka.test',
        password: 'clave-incorrecta-nucleo',
      );
      fail('expected AuthException');
    } on AuthException catch (error) {
      expect(error.message, isNotEmpty);
    }

    final ok = await client.auth.signInWithPassword(
      email: 'cliente@wammetka.test',
      password: seedPassword,
    );
    final userId = ok.user?.id;
    expect(userId, isNotNull);

    final row = await client
        .from('profiles')
        .select('rol, activo, nombre')
        .eq('id', userId!)
        .single();
    expect(row['rol'], 'cliente');
    expect(row['activo'], isTrue);

    var escalated = false;
    try {
      await client
          .from('profiles')
          .update(<String, dynamic>{'rol': 'admin'})
          .eq('id', userId);
      final after = await client
          .from('profiles')
          .select('rol')
          .eq('id', userId)
          .single();
      escalated = after['rol'] == 'admin';
    } catch (_) {
      escalated = false;
    }
    expect(escalated, isFalse);

    await client.auth.signOut();
  });
}
