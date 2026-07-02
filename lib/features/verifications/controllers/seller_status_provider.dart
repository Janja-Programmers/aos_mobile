import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/verifications/data/verification_api.dart';
import 'package:africaonlinestores/features/verifications/domain/verification_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sellerStatusProvider = FutureProvider<SellerVerificationStatus>((
  ref,
) async {
  final api = ref.watch(verificationApiProvider);

  final sellerRes = await api.getMySellerStatus();

  final sellerStatus = sellerRes.fold(
    (l) => throw l,
    (r) => r['status']?.toString(),
  );

  final verificationRes = await api.getMyVerification();

  return verificationRes.fold(
    (l) {
      // Seller exists, but no verification record yet.
      return SellerVerificationStatus(
        isSeller: true,
        isVerified: false,
        status: VerificationStatus.notSubmitted,
        sellerStatus: sellerStatus,
      );
    },
    (r) {
      final data = r['data'] is Map
          ? asJsonMap(r['data'] as Map)
          : <String, dynamic>{};

      final verification = data['verification'] is Map
          ? asJsonMap(data['verification'] as Map)
          : <String, dynamic>{};

      final rawStatus =
          data['verification_status'] ??
          data['status'] ??
          verification['status'];

      return SellerVerificationStatus(
        isSeller: true,
        isVerified: data['is_verified'] == true,
        status: SellerVerificationStatus.mapStatus(rawStatus?.toString()),
        verifiedOn:
            data['verified_on']?.toString() ??
            verification['verified_on']?.toString(),
        rejectionReason: verification['rejection_reason']?.toString(),
        sellerStatus: sellerStatus,
      );
    },
  );
});
