import 'package:supabase_flutter/supabase_flutter.dart';

import 'env.dart';

/// Holds the client after [bootstrapSupabase]. Null if dart-define is missing.
abstract final class SupabaseHolder {
  static SupabaseClient? client;
}

Future<void> bootstrapSupabase() async {
  if (!Env.isConfigured) {
    SupabaseHolder.client = null;
    return;
  }
  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.clientKey,
  );
  SupabaseHolder.client = Supabase.instance.client;
}
