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
    final data = json["data"] ?? {};
    final verification = data["verification"] ?? {};

    final rawStatus = data["verification_status"] ?? verification["status"];

    return SellerVerificationStatus(
      isSeller: data["is_seller"] ?? false,
      isVerified: data["is_verified"] ?? false,
      status: _mapStatus(rawStatus),
      verifiedOn: verification["verified_on"],
      rejectionReason: verification["rejection_reason"],
    );
  }

  static VerificationStatus _mapStatus(String? status) {
    switch (status) {
      case "Pending":
      case "Reviewing":
        return VerificationStatus.pending;
      case "Approved":
        return VerificationStatus.approved;
      case "Rejected":
        return VerificationStatus.rejected;
      default:
        return VerificationStatus.notSubmitted;
    }
  }
}
