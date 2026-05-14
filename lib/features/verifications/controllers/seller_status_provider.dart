import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/verifications/data/verification_api.dart';
import 'package:africaonlinestores/features/verifications/domain/verification_status.dart';

final sellerStatusProvider = FutureProvider<SellerVerificationStatus>((
  ref,
) async {
  final api = ref.watch(verificationApiProvider);

  final res = await api.getMySellerStatus();

  return res.fold(
    (l) {
      throw l;
    },
    (r) {
      final parsed = SellerVerificationStatus.fromJson(r);

      return parsed;
    },
  );
});
