import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/verifications/domain/verification_status.dart';

class UserVerificationStatus {
  const UserVerificationStatus({
    required this.isVerified,
    required this.status,
    this.verifiedOn,
    this.rejectionReason,
    this.phoneNumber,
    this.idType,
  });

  final bool isVerified;
  final VerificationStatus status;
  final String? verifiedOn;
  final String? rejectionReason;
  final String? phoneNumber;
  final String? idType;

  bool get isPending => status == VerificationStatus.pending;
  bool get isRejected => status == VerificationStatus.rejected;
  bool get canStart => status == VerificationStatus.notSubmitted || isRejected;

  factory UserVerificationStatus.notSubmitted() {
    return const UserVerificationStatus(
      isVerified: false,
      status: VerificationStatus.notSubmitted,
    );
  }

  factory UserVerificationStatus.fromJson(Map<String, dynamic> json) {
    final data = _extractData(json);
    final verification = data['verification'] is Map
        ? asJsonMap(data['verification'] as Map)
        : data;

    final rawStatus =
        data['verification_status'] ??
        data['identity_verification_status'] ??
        data['user_verification_status'] ??
        verification['status'];

    final status = SellerVerificationStatus.mapStatus(rawStatus?.toString());
    final verified =
        data['is_verified'] == true ||
        data['identity_verified'] == true ||
        data['is_identity_verified'] == true ||
        status == VerificationStatus.approved;

    return UserVerificationStatus(
      isVerified: verified,
      status: verified ? VerificationStatus.approved : status,
      verifiedOn:
          data['verified_on']?.toString() ??
          verification['verified_on']?.toString(),
      rejectionReason:
          verification['rejection_reason']?.toString() ??
          data['rejection_reason']?.toString(),
      phoneNumber:
          verification['phone_number']?.toString() ??
          data['phone_number']?.toString(),
      idType:
          verification['id_type']?.toString() ??
          verification['document_type']?.toString() ??
          data['id_type']?.toString(),
    );
  }

  static Map<String, dynamic> _extractData(Map<String, dynamic> json) {
    if (json['data'] is Map) {
      return asJsonMap(json['data'] as Map);
    }
    if (json['message'] is Map) {
      final message = asJsonMap(json['message'] as Map);
      if (message['data'] is Map) {
        return asJsonMap(message['data'] as Map);
      }
      return message;
    }
    return json;
  }
}

class UserVerificationDraft {
  const UserVerificationDraft({
    this.countryCode = '+254',
    this.phoneNumber = '',
    this.otp = '',
    this.phoneOtpSent = false,
    this.phoneVerified = false,
    this.idType = 'National ID',
    this.idFrontUrl,
    this.idBackUrl,
    this.selfieUrl,
  });

  final String countryCode;
  final String phoneNumber;
  final String otp;
  final bool phoneOtpSent;
  final bool phoneVerified;
  final String idType;
  final String? idFrontUrl;
  final String? idBackUrl;
  final String? selfieUrl;

  bool get hasPhone => phoneNumber.trim().length >= 7;
  bool get hasOtp => otp.trim().length >= 4;
  bool get hasFront => idFrontUrl?.trim().isNotEmpty ?? false;
  bool get hasBack => idBackUrl?.trim().isNotEmpty ?? false;
  bool get hasSelfie => selfieUrl?.trim().isNotEmpty ?? false;
  String get fullPhoneNumber => '$countryCode ${phoneNumber.trim()}'.trim();

  UserVerificationDraft copyWith({
    String? countryCode,
    String? phoneNumber,
    String? otp,
    bool? phoneOtpSent,
    bool? phoneVerified,
    String? idType,
    String? idFrontUrl,
    String? idBackUrl,
    String? selfieUrl,
  }) {
    return UserVerificationDraft(
      countryCode: countryCode ?? this.countryCode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      otp: otp ?? this.otp,
      phoneOtpSent: phoneOtpSent ?? this.phoneOtpSent,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      idType: idType ?? this.idType,
      idFrontUrl: idFrontUrl ?? this.idFrontUrl,
      idBackUrl: idBackUrl ?? this.idBackUrl,
      selfieUrl: selfieUrl ?? this.selfieUrl,
    );
  }

  Map<String, dynamic> toPayload() {
    return {
      'verification_type': 'User',
      'phone_number': fullPhoneNumber,
      'id_type': idType,
      'id_front': idFrontUrl,
      'id_back': idBackUrl,
      'selfie': selfieUrl,
      'verification_documents': [
        if (hasFront) {'document_type': 'id_front', 'attachment': idFrontUrl},
        if (hasBack) {'document_type': 'id_back', 'attachment': idBackUrl},
        if (hasSelfie) {'document_type': 'selfie', 'attachment': selfieUrl},
      ],
    };
  }
}

class UserVerificationState {
  const UserVerificationState({
    this.draft = const UserVerificationDraft(),
    this.currentStep = 0,
    this.completedSteps = const <int>{},
    this.isSendingOtp = false,
    this.isVerifyingOtp = false,
    this.isUploadingFront = false,
    this.isUploadingBack = false,
    this.isUploadingSelfie = false,
    this.isSubmitting = false,
  });

  final UserVerificationDraft draft;
  final int currentStep;
  final Set<int> completedSteps;
  final bool isSendingOtp;
  final bool isVerifyingOtp;
  final bool isUploadingFront;
  final bool isUploadingBack;
  final bool isUploadingSelfie;
  final bool isSubmitting;

  bool get isBusy =>
      isSendingOtp ||
      isVerifyingOtp ||
      isUploadingFront ||
      isUploadingBack ||
      isUploadingSelfie ||
      isSubmitting;

  UserVerificationState copyWith({
    UserVerificationDraft? draft,
    int? currentStep,
    Set<int>? completedSteps,
    bool? isSendingOtp,
    bool? isVerifyingOtp,
    bool? isUploadingFront,
    bool? isUploadingBack,
    bool? isUploadingSelfie,
    bool? isSubmitting,
  }) {
    return UserVerificationState(
      draft: draft ?? this.draft,
      currentStep: currentStep ?? this.currentStep,
      completedSteps: completedSteps ?? this.completedSteps,
      isSendingOtp: isSendingOtp ?? this.isSendingOtp,
      isVerifyingOtp: isVerifyingOtp ?? this.isVerifyingOtp,
      isUploadingFront: isUploadingFront ?? this.isUploadingFront,
      isUploadingBack: isUploadingBack ?? this.isUploadingBack,
      isUploadingSelfie: isUploadingSelfie ?? this.isUploadingSelfie,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}
