/// Comparación de versiones para auto-update. Fuente de verdad: versionCode.
abstract final class UpdateRules {
  static bool shouldOfferUpdate({
    required int localBuildNumber,
    required int? remoteVersionCode,
    required String localSemver,
    String? remoteSemver,
  }) {
    if (remoteVersionCode != null) {
      return remoteVersionCode > localBuildNumber;
    }
    final remote = remoteSemver?.trim() ?? '';
    if (remote.isEmpty) {
      return false;
    }
    return compareSemver(localSemver, remote) < 0;
  }

  /// Negativo si [a] < [b]. 1.9.0 < 1.10.0.
  static int compareSemver(String a, String b) {
    final left = _parts(a);
    final right = _parts(b);
    final n = left.length > right.length ? left.length : right.length;
    for (var i = 0; i < n; i++) {
      final l = i < left.length ? left[i] : 0;
      final r = i < right.length ? right[i] : 0;
      if (l != r) {
        return l.compareTo(r);
      }
    }
    return 0;
  }

  static List<int> _parts(String raw) {
    final core = raw.split('+').first.split('-').first.trim();
    return core
        .split('.')
        .map((p) => int.tryParse(p.replaceAll(RegExp(r'\D'), '')) ?? 0)
        .toList();
  }

  /// Si [remoteSha] está vacío, se omite la verificación.
  static bool hashMatches({
    required String remoteSha,
    required String fileShaHexLower,
  }) {
    final expected = remoteSha.trim().toLowerCase();
    if (expected.isEmpty) {
      return true;
    }
    return expected == fileShaHexLower.trim().toLowerCase();
  }
}
