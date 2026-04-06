import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/features/seller/seller_verification/controllers/verification_form_state.dart';
import 'package:africaonlinestores/features/seller/seller_verification/domain/verification.dart';
import 'package:africaonlinestores/features/seller/seller_verification/domain/verification_document.dart';

class SellerVerificationController
    extends StateNotifier<SellerVerificationState> {
  SellerVerificationController() : super(SellerVerificationState.initial());

  // --- Update Business Info ---
  void updateBasic({
    String? businessName,
    String? businessType,
    String? businessCategory,
    String? phone,
    String? email,
    String? website,
    String? address,
  }) {
    state = state.copyWith(
      data: state.data.copyWith(
        businessName: businessName,
        businessType: businessType,
        businessCategory: businessCategory,
        businessPhoneNumber: phone,
        businessEmail: email,
        businessWebsite: website,
        physicalAddress: address,
      ),
    );
  }

  // --- Documents ---
  void addDocument(VerificationDocument doc) {
    final docs = [...state.data.documents, doc];
    state = state.copyWith(data: state.data.copyWith(documents: docs));
  }

  void setUploading(String type, bool value) {
    final current = state.uploadingDocs;

    if (value) {
      state = state.copyWith(uploadingDocs: {...current, type});
    } else {
      final updated = Set<String>.from(current)..remove(type);
      state = state.copyWith(uploadingDocs: updated);
    }
  }

  bool isUploading(String type) {
    return state.uploadingDocs.contains(type);
  }

  void updateDocument(int index, VerificationDocument doc) {
    final docs = [...state.data.documents];
    docs[index] = doc;
    state = state.copyWith(data: state.data.copyWith(documents: docs));
  }

  void removeDocument(int index) {
    final docs = [...state.data.documents]..removeAt(index);
    state = state.copyWith(data: state.data.copyWith(documents: docs));
  }

  // UPDATE Verification Data
  void hydrateFromVerification(Verification verification) {
    state = state.copyWith(
      data: verification,
      currentStep: 0,
      completedSteps: {},
      mode: VerificationMode.update,
    );
  }

  // --- Navigation ---
  void nextStep() {
    state = state.copyWith(
      currentStep: state.currentStep + 1,
      completedSteps: {...state.completedSteps, state.currentStep},
    );
  }

  void previousStep() {
    state = state.copyWith(currentStep: state.currentStep - 1);
  }

  void goToStep(int step) {
    state = state.copyWith(currentStep: step);
  }

  // --- Submit ---
  Future<void> submit(
    Future<void> Function(Map<String, dynamic>) apiCall,
  ) async {
    state = state.copyWith(isSubmitting: true);

    try {
      final payload = state.data.toPayload();
      await apiCall(payload);
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }
}
