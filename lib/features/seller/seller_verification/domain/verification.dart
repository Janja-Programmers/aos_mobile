import 'package:africaonlinestores/features/seller/seller_verification/domain/verification_document.dart';

class Verification {
  final String? businessName;
  final String? businessType;
  final String? businessCategory;
  final String? businessPhoneNumber;
  final String? businessEmail;
  final String? businessWebsite;
  final String? physicalAddress;
  final List<VerificationDocument> documents;

  Verification({
    this.businessName,
    this.businessType,
    this.businessCategory,
    this.businessPhoneNumber,
    this.businessEmail,
    this.businessWebsite,
    this.physicalAddress,
    this.documents = const [],
  });

  Verification copyWith({
    String? businessName,
    String? businessType,
    String? businessCategory,
    String? businessPhoneNumber,
    String? businessEmail,
    String? businessWebsite,
    String? physicalAddress,
    List<VerificationDocument>? documents,
  }) {
    return Verification(
      businessName: businessName ?? this.businessName,
      businessType: businessType ?? this.businessType,
      businessCategory: businessCategory ?? this.businessCategory,
      businessPhoneNumber: businessPhoneNumber ?? this.businessPhoneNumber,
      businessEmail: businessEmail ?? this.businessEmail,
      businessWebsite: businessWebsite ?? this.businessWebsite,
      physicalAddress: physicalAddress ?? this.physicalAddress,
      documents: documents ?? this.documents,
    );
  }

  Map<String, dynamic> toPayload() {
    return {
      "business_name": businessName,
      "business_type": businessType,
      "business_category": businessCategory,
      "business_phone_number": businessPhoneNumber,
      "business_email": businessEmail,
      "business_website": businessWebsite,
      "physical_address": physicalAddress,
      "verification_documents": documents.map((e) => e.toPayload()).toList(),
    };
  }
}
