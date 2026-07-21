import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/verifications/data/verification_api.dart';
import 'package:africaonlinestores/features/verifications/domain/verification_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sellerStatusProvider = FutureProvider<SellerVerificationStatus>((
  ref,
) async {
  final api = ref.watch(verificationApiProvider);
  final sellerRes = await api.getMySellerStatus();

  final sellerData = sellerRes.fold(
    (failure) => throw failure,
    _responseData,
  );
  final isSeller = asBool(sellerData['is_seller']);
  final sellerStatus = asNullableString(sellerData['status']);
  final sellerId = asNullableString(sellerData['seller_id']);
  final sellerType = asNullableString(sellerData['seller_type']);

  if (!isSeller) {
    return SellerVerificationStatus(
      isSeller: false,
      isVerified: false,
      status: VerificationStatus.notSubmitted,
      sellerStatus: sellerStatus,
      sellerId: sellerId,
      sellerType: sellerType,
    );
  }

  final verificationRes = await api.getMyVerification();

  return verificationRes.fold(
    (failure) {
      if (!_isMissingVerification(failure)) {
        throw failure;
      }

      return SellerVerificationStatus(
        isSeller: true,
        isVerified: false,
        status: VerificationStatus.notSubmitted,
        sellerStatus: sellerStatus,
        sellerId: sellerId,
        sellerType: sellerType,
      );
    },
    (response) {
      final data = _responseData(response);
      final verification = asJsonMap(data['verification']);
      final verificationType = asString(
        verification['verification_type'] ?? data['verification_type'],
      ).trim().toLowerCase();
      final isBusinessVerification =
          verificationType.isEmpty ||
          verificationType == 'business' ||
          verificationType == 'seller';

      if (!isBusinessVerification) {
        return SellerVerificationStatus(
          isSeller: true,
          isVerified: false,
          status: VerificationStatus.notSubmitted,
          sellerStatus: sellerStatus,
          sellerId: sellerId,
          sellerType: sellerType,
        );
      }

      final rawStatus =
          data['verification_status'] ??
          data['status'] ??
          verification['status'];
      final status = SellerVerificationStatus.mapStatus(
        asNullableString(rawStatus),
      );
      final isVerified =
          asBool(data['is_verified']) ||
          asBool(verification['is_verified']) ||
          status == VerificationStatus.approved;

      return SellerVerificationStatus(
        isSeller: true,
        isVerified: isVerified,
        status: isVerified ? VerificationStatus.approved : status,
        verifiedOn:
            asNullableString(data['verified_on']) ??
            asNullableString(verification['verified_on']),
        rejectionReason:
            asNullableString(verification['rejection_reason']) ??
            asNullableString(data['rejection_reason']),
        sellerStatus: sellerStatus,
        sellerId: sellerId,
        sellerType: sellerType,
      );
    },
  );
});

Map<String, dynamic> _responseData(Map<String, dynamic> response) {
  final data = asJsonMap(response['data']);
  return data.isEmpty ? response : data;
}

bool _isMissingVerification(Failure failure) {
  if (failure.type == FailureType.notFound || failure.statusCode == 404) {
    return true;
  }

  final error = failure.error?.trim().toUpperCase() ?? '';
  return error == 'VERIFICATION_NOT_FOUND' ||
      error == 'NO_VERIFICATION' ||
      error == 'NOT_FOUND';
}
