import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/verifications/data/verification_api.dart';
import 'package:africaonlinestores/features/verifications/domain/verification.dart';

final myBusinessVerificationProvider = FutureProvider<BusinessVerification>((
  ref,
) async {
  final api = ref.read(verificationApiProvider);

  final res = await api.getMyVerification();

  return res.fold((l) => throw l, (r) {
    final data = r["data"] ?? {};
    final verification = data["verification"] ?? {};

    return BusinessVerification.fromJson(verification);
  });
});
