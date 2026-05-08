import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/sellers/seller_verification/data/verification_api.dart';
import 'package:africaonlinestores/features/sellers/seller_verification/domain/verification.dart';

final myVerificationProvider = FutureProvider<Verification>((ref) async {
  final api = ref.read(verificationApiProvider);

  final res = await api.getMyVerification();

  return res.fold((l) => throw l, (r) {
    final data = r["data"] ?? {};
    final verification = data["verification"] ?? {};

    return Verification.fromJson(verification);
  });
});
