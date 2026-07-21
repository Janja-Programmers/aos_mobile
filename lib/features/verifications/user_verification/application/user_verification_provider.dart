import 'dart:async';
import 'dart:io';

import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/media/data/media_upload_api_provider.dart';
import 'package:africaonlinestores/core/media/domain/media_upload_purpose.dart';
import 'package:africaonlinestores/core/media/domain/media_upload_result.dart';
import 'package:africaonlinestores/core/media/helpers/media_helper.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/features/verifications/domain/verification_status.dart';
import 'package:africaonlinestores/features/verifications/domain/verification_type.dart';
import 'package:africaonlinestores/features/verifications/user_verification/data/user_verification_api.dart';
import 'package:africaonlinestores/features/verifications/user_verification/data/user_verification_draft_storage.dart';
import 'package:africaonlinestores/features/verifications/user_verification/domain/user_verification_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final userVerificationStatusProvider = FutureProvider<UserVerificationStatus>((
  ref,
) async {
  final api = ref.read(userVerificationApiProvider);
  final res = await api.getMyUserVerification();

  return res.fold((failure) {
    final auth = ref.read(authControllerProvider);
    final user = auth.asAuthenticated?.user;
    final verified = user?.isVerified ?? false;

    if (verified) {
      return const UserVerificationStatus(
        isVerified: true,
        status: VerificationStatus.approved,
      );
    }

    if (_isMissingVerification(failure)) {
      return UserVerificationStatus.notSubmitted();
    }

    throw failure;
  }, UserVerificationStatus.fromJson);
});

final userVerificationDraftStorageProvider =
    Provider<UserVerificationDraftStorage>((ref) {
      return const UserVerificationDraftStorage();
    });

final userVerificationControllerProvider =
    StateNotifierProvider<UserVerificationController, UserVerificationState>((
      ref,
    ) {
      return UserVerificationController(ref);
    });

class UserVerificationController extends StateNotifier<UserVerificationState> {
  UserVerificationController(this.ref) : super(const UserVerificationState());

  final Ref ref;
  Timer? _draftSaveTimer;

  String? get _currentUserId {
    return ref.read(authControllerProvider).asAuthenticated?.user.email;
  }

  void reset({
    UserVerificationStatus? status,
    VerificationType verificationType = VerificationType.individual,
  }) {
    _draftSaveTimer?.cancel();
    final idType = status?.idType?.trim();

    state = UserVerificationState(
      draft: UserVerificationDraft(
        verificationType: verificationType,
        legalName: status?.legalName?.trim() ?? '',
        phoneNumber: status?.phoneNumber?.trim() ?? '',
        idType: idType == null || idType.isEmpty ? 'National ID' : idType,
      ),
    );
  }

  Future<bool> restoreLocalDraft() async {
    final userId = _currentUserId;
    if (userId == null || userId.trim().isEmpty) return false;

    state = state.copyWith(isRestoringDraft: true);

    try {
      final saved = await ref
          .read(userVerificationDraftStorageProvider)
          .read(userId);

      if (saved == null || !saved.draft.hasProgress) {
        return false;
      }

      final restoredDraft = saved.draft.copyWith(
        verificationType: state.draft.verificationType,
      );
      final completed = _completedStepsFor(restoredDraft);
      final highestAccessible = _highestAccessibleStep(restoredDraft);
      final restoredStep = saved.currentStep
          .clamp(0, highestAccessible)
          .toInt();

      state = state.copyWith(
        draft: restoredDraft,
        currentStep: restoredStep,
        completedSteps: completed,
      );

      return true;
    } finally {
      state = state.copyWith(isRestoringDraft: false);
    }
  }

  Future<void> saveLocalDraft() async {
    _draftSaveTimer?.cancel();
    final userId = _currentUserId;
    if (userId == null || userId.trim().isEmpty) return;

    final storage = ref.read(userVerificationDraftStorageProvider);
    final snapshot = state;

    if (!snapshot.draft.hasProgress && snapshot.currentStep == 0) {
      await storage.clear(userId);
      return;
    }

    await storage.write(
      userId: userId,
      draft: snapshot.draft,
      currentStep: snapshot.currentStep,
    );
  }

  Future<void> clearLocalDraft() async {
    _draftSaveTimer?.cancel();
    final userId = _currentUserId;
    if (userId == null || userId.trim().isEmpty) return;

    await ref.read(userVerificationDraftStorageProvider).clear(userId);
  }

  Future<void> _saveLocalDraftSilently() async {
    try {
      await saveLocalDraft();
    } on Exception {
      return;
    }
  }

  void _scheduleLocalDraftSave() {
    _draftSaveTimer?.cancel();
    _draftSaveTimer = Timer(const Duration(milliseconds: 350), () {
      unawaited(_saveLocalDraftSilently());
    });
  }

  void setVerificationType(VerificationType verificationType) {
    if (state.draft.verificationType == verificationType) return;

    state = state.copyWith(
      draft: state.draft.copyWith(verificationType: verificationType),
    );
  }

  void updatePersonalDetails({String? legalName, String? phoneNumber}) {
    final updatedDraft = state.draft.copyWith(
      legalName: legalName,
      phoneNumber: phoneNumber,
    );

    state = state.copyWith(
      draft: updatedDraft,
      completedSteps: _completedStepsFor(updatedDraft),
    );
    _scheduleLocalDraftSave();
  }

  void setIdType(String idType) {
    state = state.copyWith(draft: state.draft.copyWith(idType: idType));
    _scheduleLocalDraftSave();
  }

  bool isStepAccessible(int step) {
    final target = step.clamp(0, 3).toInt();

    switch (target) {
      case 0:
        return true;
      case 1:
        return missingForStep(0) == null;
      case 2:
        return missingForStep(0) == null && missingForStep(1) == null;
      case 3:
        return missingForStep(0) == null &&
            missingForStep(1) == null &&
            missingForStep(2) == null;
      default:
        return false;
    }
  }

  bool goToStep(int step) {
    final target = step.clamp(0, 3).toInt();
    if (!isStepAccessible(target)) return false;

    state = state.copyWith(currentStep: target);
    _scheduleLocalDraftSave();
    return true;
  }

  bool previousStep() {
    if (state.currentStep <= 0) return false;

    state = state.copyWith(currentStep: state.currentStep - 1);
    _scheduleLocalDraftSave();
    return true;
  }

  void markCurrentStepComplete() {
    state = state.copyWith(
      completedSteps: {...state.completedSteps, state.currentStep},
    );
    _scheduleLocalDraftSave();
  }

  String? missingForStep(int step) {
    final draft = state.draft;

    switch (step) {
      case 0:
        if (!draft.hasLegalName) return 'Enter your legal name.';
        if (draft.legalName.trim().length < 2) {
          return 'Enter a valid legal name.';
        }
        if (!draft.hasPhoneNumber) return 'Enter your phone number.';
        if (!_isValidPhoneNumber(draft.phoneNumber)) {
          return 'Enter a valid phone number, including the country code.';
        }
        return null;
      case 1:
        if (!draft.hasFront) return 'Upload the front side of your ID.';
        if (!draft.hasBack) return 'Upload the back side of your ID.';
        return null;
      case 2:
        if (!draft.hasSelfie) return 'Take or upload a selfie.';
        return null;
      case 3:
        if (missingForStep(0) != null ||
            missingForStep(1) != null ||
            missingForStep(2) != null) {
          return 'Complete all verification steps before submitting.';
        }
        return null;
      default:
        return null;
    }
  }

  bool canContinue(int step) => missingForStep(step) == null;

  Future<Either<Failure, void>> uploadDocument({
    required File file,
    required bool front,
  }) async {
    state = state.copyWith(
      isUploadingFront: front ? true : null,
      isUploadingBack: front ? null : true,
    );

    try {
      final uploaded = await _uploadVerificationImage(file);

      if (uploaded == null) {
        return Either.left(const Failure('Upload failed. Please try again.'));
      }

      final updatedDraft = front
          ? state.draft.copyWith(idFrontUrl: uploaded.mediaId)
          : state.draft.copyWith(idBackUrl: uploaded.mediaId);

      state = state.copyWith(
        draft: updatedDraft,
        completedSteps: _completedStepsFor(updatedDraft),
      );
      await _saveLocalDraftSilently();

      return Either.right(null);
    } finally {
      state = state.copyWith(
        isUploadingFront: front ? false : null,
        isUploadingBack: front ? null : false,
      );
    }
  }

  Future<Either<Failure, void>> uploadSelfie(File file) async {
    state = state.copyWith(isUploadingSelfie: true);

    try {
      final uploaded = await _uploadVerificationImage(file);

      if (uploaded == null) {
        return Either.left(const Failure('Upload failed. Please try again.'));
      }

      final updatedDraft = state.draft.copyWith(selfieUrl: uploaded.mediaId);
      state = state.copyWith(
        draft: updatedDraft,
        completedSteps: _completedStepsFor(updatedDraft),
      );
      await _saveLocalDraftSilently();

      return Either.right(null);
    } finally {
      state = state.copyWith(isUploadingSelfie: false);
    }
  }

  Future<MediaUploadResult?> _uploadVerificationImage(File file) {
    return MediaHelper.uploadSingle(
      ref: ref,
      file: file,
      uploadFn: (uploadFile) => ref
          .read(mediaUploadApiProvider)
          .uploadMedia(
            file: uploadFile,
            purpose: MediaUploadPurpose.verificationDocument,
          ),
    );
  }

  Future<Either<Failure, void>> submit() async {
    final missing = missingForStep(3);
    if (missing != null) return Either.left(Failure(missing));

    state = state.copyWith(isSubmitting: true);

    try {
      final res = await ref
          .read(userVerificationApiProvider)
          .submitUserVerification(payload: state.draft.toPayload());

      return res.fold((failure) async => Either<Failure, void>.left(failure), (
        _,
      ) async {
        await clearLocalDraft();
        ref.invalidate(userVerificationStatusProvider);
        return Either<Failure, void>.right(null);
      });
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  static bool _isValidPhoneNumber(String value) {
    final compact = value.trim().replaceAll(RegExp(r'[\s()\-]'), '');
    return RegExp(r'^\+?[0-9]{7,15}$').hasMatch(compact);
  }

  static Set<int> _completedStepsFor(UserVerificationDraft draft) {
    final completed = <int>{};

    if (draft.hasLegalName &&
        draft.legalName.trim().length >= 2 &&
        draft.hasPhoneNumber &&
        _isValidPhoneNumber(draft.phoneNumber)) {
      completed.add(0);
    }
    if (draft.hasFront && draft.hasBack) {
      completed.add(1);
    }
    if (draft.hasSelfie) {
      completed.add(2);
    }

    return completed;
  }

  static int _highestAccessibleStep(UserVerificationDraft draft) {
    if (!draft.hasLegalName ||
        draft.legalName.trim().length < 2 ||
        !draft.hasPhoneNumber ||
        !_isValidPhoneNumber(draft.phoneNumber)) {
      return 0;
    }
    if (!draft.hasFront || !draft.hasBack) return 1;
    if (!draft.hasSelfie) return 2;
    return 3;
  }

  @override
  void dispose() {
    _draftSaveTimer?.cancel();
    super.dispose();
  }
}

bool _isMissingVerification(Failure failure) {
  if (failure.type == FailureType.notFound || failure.statusCode == 404) {
    return true;
  }

  final error = failure.error?.trim().toUpperCase() ?? '';
  return error == 'VERIFICATION_NOT_FOUND' ||
      error == 'NO_VERIFICATION' ||
      error == 'NOT_FOUND';
}
