import 'package:africaonlinestores/features/seller/seller_verification/domain/verification.dart';

class SellerVerificationState {
  final Verification data;
  final int currentStep;
  final bool isSubmitting;
  final Set<int> completedSteps;

  SellerVerificationState({
    required this.data,
    required this.currentStep,
    required this.isSubmitting,
    required this.completedSteps,
  });

  factory SellerVerificationState.initial() {
    return SellerVerificationState(
      data: Verification(),
      currentStep: 0,
      isSubmitting: false,
      completedSteps: {},
    );
  }

  SellerVerificationState copyWith({
    Verification? data,
    int? currentStep,
    bool? isSubmitting,
    Set<int>? completedSteps,
  }) {
    return SellerVerificationState(
      data: data ?? this.data,
      currentStep: currentStep ?? this.currentStep,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      completedSteps: completedSteps ?? this.completedSteps,
    );
  }
}
