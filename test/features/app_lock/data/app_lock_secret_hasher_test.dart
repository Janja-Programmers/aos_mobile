import 'package:africaonlinestores/features/app_lock/data/app_lock_secret_hasher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('PBKDF2 digest verifies the right secret and rejects another', () async {
    const Pbkdf2AppLockSecretHasher hasher = Pbkdf2AppLockSecretHasher(
      iterations: 20,
    );
    final AppLockSecretDigest digest = await hasher.create('1234');

    expect(digest.hash, isNot('1234'));
    expect(
      await hasher.verify(
        secret: '1234',
        expectedHash: digest.hash,
        salt: digest.salt,
        iterations: digest.iterations,
      ),
      isTrue,
    );
    expect(
      await hasher.verify(
        secret: '0000',
        expectedHash: digest.hash,
        salt: digest.salt,
        iterations: digest.iterations,
      ),
      isFalse,
    );
  });
}
