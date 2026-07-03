import 'package:africaonlinestores/core/utils/json_utils.dart';

class VerificationDocument {
  VerificationDocument({
    this.documentType,
    this.documentNumber,
    this.issueDate,
    this.expiryDate,
    this.attachment,
    this.mediaId,
  });

  final String? documentType;
  final String? documentNumber;
  final String? issueDate;
  final String? expiryDate;
  final String? attachment;
  final String? mediaId;

  VerificationDocument copyWith({
    String? documentType,
    String? documentNumber,
    String? issueDate,
    String? expiryDate,
    String? attachment,
    String? mediaId,
  }) {
    return VerificationDocument(
      documentType: documentType ?? this.documentType,
      documentNumber: documentNumber ?? this.documentNumber,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      attachment: attachment ?? this.attachment,
      mediaId: mediaId ?? this.mediaId,
    );
  }

  Map<String, dynamic> toPayload() {
    return {
      'document_type': documentType,
      'document_number': documentNumber,
      'issue_date': issueDate,
      'expiry_date': expiryDate,
      'attachment': attachment,
      'media': mediaId,
      'media_id': mediaId,
    };
  }

  factory VerificationDocument.fromJson(Map<String, dynamic> json) {
    final mediaId = asNullableString(
      json['media_id'] ?? json['media'] ?? json['attachment_media'],
    );
    return VerificationDocument(
      documentType: asNullableString(json['document_type']),
      documentNumber: asNullableString(json['document_number']),
      issueDate: asNullableString(json['issue_date']),
      expiryDate: asNullableString(json['expiry_date']),
      attachment: asNullableString(json['attachment']),
      mediaId: mediaId,
    );
  }
}
