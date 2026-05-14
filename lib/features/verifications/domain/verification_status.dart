enum VerificationStatus { notSubmitted, pending, approved, rejected }

class SellerVerificationStatus {
  final bool isSeller;
  final bool isVerified;
  final VerificationStatus status;
  final String? verifiedOn;
  final String? rejectionReason;

  const SellerVerificationStatus({
    required this.isSeller,
    required this.isVerified,
    required this.status,
    this.verifiedOn,
    this.rejectionReason,
  });

  factory SellerVerificationStatus.fromJson(Map<String, dynamic> json) {
    final data = json["data"] is Map
        ? Map<String, dynamic>.from(json["data"] as Map)
        : <String, dynamic>{};

    final verification = data["verification"] is Map
        ? Map<String, dynamic>.from(data["verification"] as Map)
        : <String, dynamic>{};

    final rawStatus =
        data["verification_status"] ?? data["status"] ?? verification["status"];

    return SellerVerificationStatus(
      isSeller: data["is_seller"] == true,
      isVerified: data["is_verified"] == true,
      status: mapStatus(rawStatus?.toString()),
      verifiedOn:
          data["verified_on"]?.toString() ??
          verification["verified_on"]?.toString(),
      rejectionReason: verification["rejection_reason"]?.toString(),
    );
  }

  static VerificationStatus mapStatus(String? status) {
    switch (status?.trim().toLowerCase()) {
      case "pending":
      case "reviewing":
        return VerificationStatus.pending;
      case "approved":
        return VerificationStatus.approved;
      case "rejected":
        return VerificationStatus.rejected;
      default:
        return VerificationStatus.notSubmitted;
    }
  }
}
