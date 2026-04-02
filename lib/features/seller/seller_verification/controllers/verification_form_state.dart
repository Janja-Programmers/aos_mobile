import 'package:africaonlinestores/features/seller/seller_verification/domain/verification.dart';

class SellerVerificationState {
  final Verification data;
  final int currentStep;
  final bool isSubmitting;
  final Set<int> completedSteps;
  final Set<String> uploadingDocs;

  SellerVerificationState({
    required this.data,
    required this.currentStep,
    required this.isSubmitting,
    required this.completedSteps,
    Set<String>? uploadingDocs,
  }) : uploadingDocs = uploadingDocs ?? {};

  factory SellerVerificationState.initial() {
    return SellerVerificationState(
      data: Verification(),
      currentStep: 0,
      isSubmitting: false,
      completedSteps: const {},
      uploadingDocs: const {},
    );
  }

  SellerVerificationState copyWith({
    Verification? data,
    int? currentStep,
    bool? isSubmitting,
    Set<int>? completedSteps,
    Set<String>? uploadingDocs,
  }) {
    return SellerVerificationState(
      data: data ?? this.data,
      currentStep: currentStep ?? this.currentStep,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      completedSteps: completedSteps ?? this.completedSteps,
      uploadingDocs: uploadingDocs ?? this.uploadingDocs,
    );
  }
}
