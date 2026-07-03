import 'dart:io';

import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/media/data/media_upload_api_provider.dart';
import 'package:africaonlinestores/core/media/domain/media_upload_purpose.dart';
import 'package:africaonlinestores/core/media/helpers/media_helper.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/features/verifications/domain/verification_status.dart';
import 'package:africaonlinestores/features/verifications/user_verification/data/user_verification_api.dart';
import 'package:africaonlinestores/features/verifications/user_verification/domain/user_verification_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final userVerificationStatusProvider = FutureProvider<UserVerificationStatus>((
  ref,
) async {
  final api = ref.read(userVerificationApiProvider);
  final res = await api.getMyUserVerification();

  return res.fold((_) {
    final auth = ref.read(authControllerProvider);
    final user = auth.asAuthenticated?.user;
    final verified = user?.isVerified ?? false;
    return verified
        ? const UserVerificationStatus(
            isVerified: true,
            status: VerificationStatus.approved,
          )
        : UserVerificationStatus.notSubmitted();
  }, UserVerificationStatus.fromJson);
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

  void updatePhone({String? countryCode, String? phoneNumber, String? otp}) {
    state = state.copyWith(
      draft: state.draft.copyWith(
        countryCode: countryCode,
        phoneNumber: phoneNumber,
        otp: otp,
        phoneVerified: phoneNumber == null ? null : false,
      ),
    );
  }

  void setIdType(String idType) {
    state = state.copyWith(draft: state.draft.copyWith(idType: idType));
  }

  void goToStep(int step) {
    state = state.copyWith(currentStep: step.clamp(0, 3).toInt());
  }

  void markCurrentStepComplete() {
    state = state.copyWith(
      completedSteps: {...state.completedSteps, state.currentStep},
    );
  }

  String? missingForStep(int step) {
    final draft = state.draft;
    switch (step) {
      case 0:
        if (!draft.hasPhone) return 'Enter a valid phone number.';
        if (!draft.phoneVerified) return 'Verify your phone number first.';
        return null;
      case 1:
        if (!draft.hasFront) return 'Upload the front side of your ID.';
        if (!draft.hasBack) return 'Upload the back side of your ID.';
        return null;
      case 2:
        if (!draft.hasSelfie) return 'Take or upload a selfie.';
        return null;
      case 3:
        if (!draft.phoneVerified ||
            !draft.hasFront ||
            !draft.hasBack ||
            !draft.hasSelfie) {
          return 'Complete all verification steps before submitting.';
        }
        return null;
      default:
        return null;
    }
  }

  bool canContinue(int step) => missingForStep(step) == null;

  Future<Either<Failure, void>> sendOtp() async {
    final draft = state.draft;
    if (!draft.hasPhone) {
      return Either.left(const Failure('Enter a valid phone number.'));
    }

    state = state.copyWith(isSendingOtp: true);
    final res = await ref
        .read(userVerificationApiProvider)
        .sendPhoneOtp(phoneNumber: draft.fullPhoneNumber);
    state = state.copyWith(isSendingOtp: false);

    return res.fold(Either.left, (_) {
      state = state.copyWith(draft: state.draft.copyWith(phoneOtpSent: true));
      return Either.right(null);
    });
  }

  Future<Either<Failure, void>> verifyOtp() async {
    final draft = state.draft;
    if (!draft.hasPhone) {
      return Either.left(const Failure('Enter a valid phone number.'));
    }
    if (!draft.hasOtp) {
      return Either.left(const Failure('Enter the OTP sent to your phone.'));
    }

    state = state.copyWith(isVerifyingOtp: true);
    final res = await ref
        .read(userVerificationApiProvider)
        .verifyPhoneOtp(
          phoneNumber: draft.fullPhoneNumber,
          otp: draft.otp.trim(),
        );
    state = state.copyWith(isVerifyingOtp: false);

    return res.fold(Either.left, (_) {
      state = state.copyWith(
        draft: state.draft.copyWith(phoneVerified: true),
        completedSteps: {...state.completedSteps, 0},
      );
      return Either.right(null);
    });
  }

  Future<Either<Failure, void>> uploadDocument({
    required File file,
    required bool front,
  }) async {
    state = state.copyWith(
      isUploadingFront: front ? true : null,
      isUploadingBack: front ? null : true,
    );

    final uploaded = await MediaHelper.uploadSingle(
      ref: ref,
      file: file,
      uploadFn: (f) => ref
          .read(mediaUploadApiProvider)
          .uploadMedia(
            file: f,
            purpose: MediaUploadPurpose.verificationDocument,
          ),
    );

    state = state.copyWith(
      isUploadingFront: front ? false : null,
      isUploadingBack: front ? null : false,
    );

    if (uploaded == null) {
      return Either.left(const Failure('Upload failed. Please try again.'));
    }

    state = state.copyWith(
      draft: front
          ? state.draft.copyWith(idFrontUrl: uploaded.mediaId)
          : state.draft.copyWith(idBackUrl: uploaded.mediaId),
    );

    if (state.draft.hasFront && state.draft.hasBack) {
      state = state.copyWith(completedSteps: {...state.completedSteps, 1});
    }

    return Either.right(null);
  }

  Future<Either<Failure, void>> uploadSelfie(File file) async {
    state = state.copyWith(isUploadingSelfie: true);
    final uploaded = await MediaHelper.uploadSingle(
      ref: ref,
      file: file,
      uploadFn: (f) => ref
          .read(mediaUploadApiProvider)
          .uploadMedia(
            file: f,
            purpose: MediaUploadPurpose.verificationDocument,
          ),
    );
    state = state.copyWith(isUploadingSelfie: false);

    if (uploaded == null) {
      return Either.left(const Failure('Upload failed. Please try again.'));
    }

    state = state.copyWith(
      draft: state.draft.copyWith(selfieUrl: uploaded.mediaId),
      completedSteps: {...state.completedSteps, 2},
    );

    return Either.right(null);
  }

  Future<Either<Failure, void>> submit() async {
    final missing = missingForStep(3);
    if (missing != null) return Either.left(Failure(missing));

    state = state.copyWith(isSubmitting: true);
    final res = await ref
        .read(userVerificationApiProvider)
        .submitUserVerification(payload: state.draft.toPayload());
    state = state.copyWith(isSubmitting: false);

    return res.fold(Either.left, (_) {
      ref.invalidate(userVerificationStatusProvider);
      return Either.right(null);
    });
  }
}
