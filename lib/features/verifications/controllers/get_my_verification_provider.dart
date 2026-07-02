import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/verifications/data/verification_api.dart';
import 'package:africaonlinestores/features/verifications/domain/verification.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final myBusinessVerificationProvider = FutureProvider<BusinessVerification>((
  ref,
) async {
  final api = ref.read(verificationApiProvider);

  final res = await api.getMyVerification();

  return res.fold((l) => throw l, (r) {
    final data = asJsonMap(r['data']);
    final verification = asJsonMap(data['verification']);

    return BusinessVerification.fromJson(verification);
  });
});
