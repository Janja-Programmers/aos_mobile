import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

class AppLockSecretDigest {
  const AppLockSecretDigest({
    required this.hash,
    required this.salt,
    required this.iterations,
  });

  final String hash;
  final String salt;
  final int iterations;
}

abstract interface class AppLockSecretHasher {
  Future<AppLockSecretDigest> create(String secret);

  Future<bool> verify({
    required String secret,
    required String expectedHash,
    required String salt,
    required int iterations,
  });
}

class Pbkdf2AppLockSecretHasher implements AppLockSecretHasher {
  const Pbkdf2AppLockSecretHasher({this.iterations = 120000});

  final int iterations;

  @override
  Future<AppLockSecretDigest> create(String secret) async {
    final Random random = Random.secure();
    final List<int> saltBytes = List<int>.generate(
      24,
      (_) => random.nextInt(256),
      growable: false,
    );
    final String encodedSalt = base64UrlEncode(saltBytes);
    final String hash = await _deriveInBackground(
      secret: secret,
      salt: encodedSalt,
      iterations: iterations,
    );
    return AppLockSecretDigest(
      hash: hash,
      salt: encodedSalt,
      iterations: iterations,
    );
  }

  @override
  Future<bool> verify({
    required String secret,
    required String expectedHash,
    required String salt,
    required int iterations,
  }) async {
    final String actual = await _deriveInBackground(
      secret: secret,
      salt: salt,
      iterations: iterations,
    );
    return _constantTimeEquals(actual, expectedHash);
  }
}

Future<String> _deriveInBackground({
  required String secret,
  required String salt,
  required int iterations,
}) {
  final Map<String, Object> input = <String, Object>{
    'secret': secret,
    'salt': salt,
    'iterations': iterations,
  };
  return Isolate.run<String>(() => _derivePbkdf2(input));
}

String _derivePbkdf2(Map<String, Object> input) {
  final String secret = input['secret']! as String;
  final String encodedSalt = input['salt']! as String;
  final int iterations = input['iterations']! as int;
  final List<int> password = utf8.encode(secret);
  final List<int> salt = base64Url.decode(encodedSalt);
  final Hmac hmac = Hmac(sha256, password);

  final Uint8List blockInput = Uint8List(salt.length + 4)
    ..setRange(0, salt.length, salt)
    ..setRange(salt.length, salt.length + 4, const <int>[0, 0, 0, 1]);

  List<int> u = hmac.convert(blockInput).bytes;
  final Uint8List result = Uint8List.fromList(u);
  for (int i = 1; i < iterations; i++) {
    u = hmac.convert(u).bytes;
    for (int index = 0; index < result.length; index++) {
      result[index] ^= u[index];
    }
  }
  return base64UrlEncode(result);
}

bool _constantTimeEquals(String left, String right) {
  final List<int> a;
  final List<int> b;
  try {
    a = base64Url.decode(left);
    b = base64Url.decode(right);
  } on FormatException {
    return false;
  }

  int difference = a.length ^ b.length;
  final int length = min(a.length, b.length);
  for (int index = 0; index < length; index++) {
    difference |= a[index] ^ b[index];
  }
  return difference == 0;
}
