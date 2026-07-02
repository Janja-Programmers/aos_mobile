import 'package:africaonlinestores/core/utils/json_utils.dart';

enum VerificationStatus { notSubmitted, pending, approved, rejected }

class SellerVerificationStatus {
  final bool isSeller;
  final bool isVerified;
  final VerificationStatus status;
  final String? verifiedOn;
  final String? rejectionReason;

  final String? sellerStatus;
  final String? sellerId;
  final String? sellerType;

  const SellerVerificationStatus({
    required this.isSeller,
    required this.isVerified,
    required this.status,
    this.verifiedOn,
    this.rejectionReason,
    this.sellerStatus,
    this.sellerId,
    this.sellerType,
  });

  bool get isSuspended {
    return sellerStatus?.trim().toLowerCase() == 'suspended';
  }

  factory SellerVerificationStatus.fromSellerStatusJson(
    Map<String, dynamic> json,
  ) {
    final message = json['message'] is Map
        ? asJsonMap(json['message'] as Map)
        : <String, dynamic>{};

    final data = message['data'] is Map
        ? asJsonMap(message['data'] as Map)
        : <String, dynamic>{};

    return SellerVerificationStatus(
      isSeller: data['is_seller'] == true,
      isVerified: false,
      status: VerificationStatus.notSubmitted,
      sellerStatus: data['status']?.toString(),
      sellerId: data['seller_id']?.toString(),
      sellerType: data['seller_type']?.toString(),
    );
  }

  factory SellerVerificationStatus.fromVerificationJson(
    Map<String, dynamic> json, {
    String? sellerStatus,
    String? sellerId,
    String? sellerType,
  }) {
    final message = json['message'] is Map
        ? asJsonMap(json['message'] as Map)
        : <String, dynamic>{};

    final data = message['data'] is Map
        ? asJsonMap(message['data'] as Map)
        : <String, dynamic>{};

    final verification = data['verification'] is Map
        ? asJsonMap(data['verification'] as Map)
        : <String, dynamic>{};

    final rawStatus = data['verification_status'] ?? verification['status'];

    return SellerVerificationStatus(
      isSeller: data['is_seller'] == true,
      isVerified: data['is_verified'] == true,
      status: mapStatus(rawStatus?.toString()),
      verifiedOn:
          data['verified_on']?.toString() ??
          verification['verified_on']?.toString(),
      rejectionReason: verification['rejection_reason']?.toString(),
      sellerStatus: sellerStatus,
      sellerId: sellerId,
      sellerType: sellerType,
    );
  }

  SellerVerificationStatus copyWith({
    bool? isSeller,
    bool? isVerified,
    VerificationStatus? status,
    String? verifiedOn,
    String? rejectionReason,
    String? sellerStatus,
    String? sellerId,
    String? sellerType,
  }) {
    return SellerVerificationStatus(
      isSeller: isSeller ?? this.isSeller,
      isVerified: isVerified ?? this.isVerified,
      status: status ?? this.status,
      verifiedOn: verifiedOn ?? this.verifiedOn,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      sellerStatus: sellerStatus ?? this.sellerStatus,
      sellerId: sellerId ?? this.sellerId,
      sellerType: sellerType ?? this.sellerType,
    );
  }

  static VerificationStatus mapStatus(String? status) {
    switch (status?.trim().toLowerCase()) {
      case 'pending':
      case 'reviewing':
        return VerificationStatus.pending;
      case 'approved':
        return VerificationStatus.approved;
      case 'rejected':
        return VerificationStatus.rejected;
      default:
        return VerificationStatus.notSubmitted;
    }
  }
}
