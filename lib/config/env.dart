/// Compile-time config. Pass keys with `--dart-define` or
/// `--dart-define-from-file=dart_defines.local.json` (gitignored).
/// Never put `service_role` here or in an APK.
abstract final class Env {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://wwhyypadkjjbgkmlbpss.supabase.co',
  );

  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static String get clientKey =>
      pickClientKey(anon: supabaseAnonKey, publishable: supabasePublishableKey);

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && clientKey.isNotEmpty;

  /// Flutter + GoTrue aceptan el JWT `anon`. La publishable corta
  /// (`sb_publishable_…`) en este SDK puede fallar como error de red.
  static String pickClientKey({
    required String anon,
    required String publishable,
  }) {
    if (anon.startsWith('eyJ') && anon.length > 80) {
      return anon;
    }
    if (publishable.isNotEmpty) {
      return publishable;
    }
    return anon;
  }
}
