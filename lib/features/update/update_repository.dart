import '../../config/supabase_bootstrap.dart';
import 'update_models.dart';

class UpdateRepository {
  Future<AppRemoteConfig?> fetchConfig() async {
    final client = SupabaseHolder.client;
    if (client == null) {
      return null;
    }
    try {
      final row = await client
          .from('app_config')
          .select(
            'version_code, latest_version, apk_url, sha256, force_update, changelog',
          )
          .eq('id', 1)
          .maybeSingle()
          .timeout(const Duration(seconds: 10));
      if (row == null) {
        return null;
      }
      return AppRemoteConfig.fromMap(row);
    } catch (_) {
      return null;
    }
  }
}
