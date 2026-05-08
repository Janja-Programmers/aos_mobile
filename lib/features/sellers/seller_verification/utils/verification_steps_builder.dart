import 'package:flutter/material.dart';

import 'package:africaonlinestores/features/sellers/seller_verification/domain/verification.dart';
import 'package:africaonlinestores/features/sellers/seller_verification/presentation/steps/basic_info_step.dart';
import 'package:africaonlinestores/features/sellers/seller_verification/presentation/steps/document_step.dart';
import 'package:africaonlinestores/features/sellers/seller_verification/presentation/steps/review_step.dart';

typedef StepBuilder = Widget Function(BuildContext context);
typedef StepValidator = bool Function(Verification data);

class VerificationStepDef {
  const VerificationStepDef({
    required this.id,
    required this.title,
    required this.builder,
    required this.validator,
  });

  final String id;
  final String title;
  final StepBuilder builder;
  final StepValidator validator;
}

List<VerificationStepDef> buildVerificationSteps() {
  return [
    VerificationStepDef(
      id: "basic",
      title: "Business Info",
      builder: (context) => const BasicInfoStep(),
      validator: (data) {
        return (data.businessName ?? "").isNotEmpty &&
            (data.businessType ?? "").isNotEmpty &&
            (data.businessCategory ?? "").isNotEmpty;
      },
    ),
    VerificationStepDef(
      id: "details",
      title: "Documents",
      builder: (context) => const DocumentsStep(),
      validator: (data) {
        return data.documents.isNotEmpty;
      },
    ),
    VerificationStepDef(
      id: "review",
      title: "Review",
      builder: (context) => const ReviewStep(),
      validator: (_) => true,
    ),
  ];
}
