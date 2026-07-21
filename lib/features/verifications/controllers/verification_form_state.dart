import 'package:africaonlinestores/features/verifications/domain/verification.dart';
import 'package:africaonlinestores/features/verifications/domain/verification_type.dart';

enum VerificationMode { create, update }

class SellerVerificationState {
  final BusinessVerification data;
  final int currentStep;
  final bool isSubmitting;
  final Set<int> completedSteps;
  final Set<String> uploadingDocs;
  final VerificationMode mode;

  SellerVerificationState({
    required this.data,
    required this.currentStep,
    required this.isSubmitting,
    required this.completedSteps,
    required this.mode,
    Set<String>? uploadingDocs,
  }) : uploadingDocs = uploadingDocs ?? {};

  factory SellerVerificationState.initial({
    VerificationType verificationType = VerificationType.business,
  }) {
    return SellerVerificationState(
      data: BusinessVerification(verificationType: verificationType),
      currentStep: 0,
      isSubmitting: false,
      completedSteps: const {},
      uploadingDocs: const {},
      mode: VerificationMode.create,
    );
  }

  SellerVerificationState copyWith({
    BusinessVerification? data,
    int? currentStep,
    bool? isSubmitting,
    Set<int>? completedSteps,
    Set<String>? uploadingDocs,
    VerificationMode? mode,
  }) {
    return SellerVerificationState(
      data: data ?? this.data,
      currentStep: currentStep ?? this.currentStep,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      completedSteps: completedSteps ?? this.completedSteps,
      uploadingDocs: uploadingDocs ?? this.uploadingDocs,
      mode: mode ?? this.mode,
    );
  }
}
