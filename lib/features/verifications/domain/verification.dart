import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/verifications/domain/verification_document.dart';

class BusinessVerification {
  final String verificationType;
  final String? businessName;
  final String? businessType;
  final String? businessCategory;
  final String? businessPhoneNumber;
  final String? businessEmail;
  final String? businessWebsite;
  final String? physicalAddress;
  final List<VerificationDocument> documents;

  BusinessVerification({
    this.verificationType = 'Business',
    this.businessName,
    this.businessType,
    this.businessCategory,
    this.businessPhoneNumber,
    this.businessEmail,
    this.businessWebsite,
    this.physicalAddress,
    this.documents = const [],
  });

  BusinessVerification copyWith({
    String? verificationType,
    String? businessName,
    String? businessType,
    String? businessCategory,
    String? businessPhoneNumber,
    String? businessEmail,
    String? businessWebsite,
    String? physicalAddress,
    List<VerificationDocument>? documents,
  }) {
    return BusinessVerification(
      verificationType: verificationType ?? this.verificationType,
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
      'verification_type': verificationType,
      'business_name': businessName,
      'business_type': businessType,
      'business_category': businessCategory,
      'business_phone_number': businessPhoneNumber,
      'business_email': businessEmail,
      'business_website': businessWebsite,
      'business_address': physicalAddress,
      'verification_documents': documents.map((e) => e.toPayload()).toList(),
    };
  }

  factory BusinessVerification.fromJson(Map<String, dynamic> json) {
    return BusinessVerification(
      verificationType: asString(
        json['verification_type'],
        fallback: 'Business',
      ),
      businessName: asNullableString(json['business_name']),
      businessType: asNullableString(json['business_type']),
      businessCategory: asNullableString(json['business_category']),
      businessPhoneNumber: asNullableString(json['business_phone_number']),
      businessEmail: asNullableString(json['business_email']),
      businessWebsite: asNullableString(json['business_website']),
      physicalAddress: asNullableString(json['physical_address']),
      documents: asJsonMapList(
        json['verification_documents'],
      ).map(VerificationDocument.fromJson).toList(growable: false),
    );
  }
}
