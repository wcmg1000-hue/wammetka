import 'package:flutter_test/flutter_test.dart';

import 'package:wammetka/features/update/update_rules.dart';

void main() {
  group('versionCode', () {
    test('igual no ofrece update', () {
      expect(
        UpdateRules.shouldOfferUpdate(
          localBuildNumber: 4,
          remoteVersionCode: 4,
          localSemver: '0.1.0',
          remoteSemver: '0.2.0',
        ),
        isFalse,
      );
    });

    test('remoto mayor ofrece update (ignora semver)', () {
      expect(
        UpdateRules.shouldOfferUpdate(
          localBuildNumber: 4,
          remoteVersionCode: 5,
          localSemver: '0.1.0',
          remoteSemver: '0.1.0',
        ),
        isTrue,
      );
    });

    test('remoto menor no ofrece', () {
      expect(
        UpdateRules.shouldOfferUpdate(
          localBuildNumber: 5,
          remoteVersionCode: 4,
          localSemver: '0.1.0',
        ),
        isFalse,
      );
    });
  });

  group('semver fallback si version_code es null', () {
    test('1.9.0 vs 1.10.0 detecta mayor', () {
      expect(UpdateRules.compareSemver('1.9.0', '1.10.0'), lessThan(0));
      expect(
        UpdateRules.shouldOfferUpdate(
          localBuildNumber: 1,
          remoteVersionCode: null,
          localSemver: '1.9.0',
          remoteSemver: '1.10.0',
        ),
        isTrue,
      );
    });

    test('igual semver no ofrece', () {
      expect(
        UpdateRules.shouldOfferUpdate(
          localBuildNumber: 1,
          remoteVersionCode: null,
          localSemver: '0.1.0',
          remoteSemver: '0.1.0',
        ),
        isFalse,
      );
    });
  });

  group('SHA-256', () {
    test('remoto vacío omite verificación', () {
      expect(
        UpdateRules.hashMatches(remoteSha: '', fileShaHexLower: 'abc'),
        isTrue,
      );
    });

    test('coincide en minúsculas', () {
      expect(
        UpdateRules.hashMatches(remoteSha: 'ABCdef', fileShaHexLower: 'abcdef'),
        isTrue,
      );
    });

    test('mismatch no instala', () {
      expect(
        UpdateRules.hashMatches(remoteSha: 'aaa', fileShaHexLower: 'bbb'),
        isFalse,
      );
    });
  });
}
