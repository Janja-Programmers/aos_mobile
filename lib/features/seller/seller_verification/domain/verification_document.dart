class VerificationDocument {
  final String? documentType;
  final String? documentNumber;
  final String? issueDate;
  final String? expiryDate;
  final String? attachment;

  VerificationDocument({
    this.documentType,
    this.documentNumber,
    this.issueDate,
    this.expiryDate,
    this.attachment,
  });

  VerificationDocument copyWith({
    String? documentType,
    String? documentNumber,
    String? issueDate,
    String? expiryDate,
    String? attachment,
  }) {
    return VerificationDocument(
      documentType: documentType ?? this.documentType,
      documentNumber: documentNumber ?? this.documentNumber,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      attachment: attachment ?? this.attachment,
    );
  }

  Map<String, dynamic> toPayload() {
    return {
      "document_type": documentType,
      "document_number": documentNumber,
      "issue_date": issueDate,
      "expiry_date": expiryDate,
      "attachment": attachment,
    };
  }
}
