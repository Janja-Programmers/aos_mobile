import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/verifications/domain/verification_status.dart';
import 'package:africaonlinestores/features/verifications/domain/verification_type.dart';

class UserVerificationStatus {
  const UserVerificationStatus({
    required this.isVerified,
    required this.status,
    this.verifiedOn,
    this.rejectionReason,
    this.idType,
    this.legalName,
    this.phoneNumber,
    this.verificationType,
  });

  final bool isVerified;
  final VerificationStatus status;
  final String? verifiedOn;
  final String? rejectionReason;
  final String? idType;
  final String? legalName;
  final String? phoneNumber;
  final String? verificationType;

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

    final verificationType =
        asNullableString(verification['verification_type']) ??
        asNullableString(data['verification_type']);
    final normalizedType = verificationType?.trim().toLowerCase() ?? '';
    final isUserVerification =
        normalizedType.isEmpty ||
        normalizedType == 'user' ||
        normalizedType == 'individual' ||
        normalizedType == 'personal';

    if (!isUserVerification) {
      return UserVerificationStatus.notSubmitted();
    }

    final status = SellerVerificationStatus.mapStatus(
      asNullableString(rawStatus),
    );
    final verified =
        asBool(data['is_verified']) ||
        asBool(data['identity_verified']) ||
        asBool(data['is_identity_verified']) ||
        asBool(verification['is_verified']) ||
        status == VerificationStatus.approved;

    return UserVerificationStatus(
      isVerified: verified,
      status: verified ? VerificationStatus.approved : status,
      verifiedOn:
          asNullableString(data['verified_on']) ??
          asNullableString(verification['verified_on']),
      rejectionReason:
          asNullableString(verification['rejection_reason']) ??
          asNullableString(data['rejection_reason']),
      idType:
          asNullableString(verification['id_type']) ??
          asNullableString(verification['document_type']) ??
          asNullableString(data['id_type']),
      legalName:
          asNullableString(verification['legal_name']) ??
          asNullableString(data['legal_name']),
      phoneNumber:
          asNullableString(verification['phone_number']) ??
          asNullableString(data['phone_number']),
      verificationType: verificationType,
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
    this.verificationType = VerificationType.individual,
    this.legalName = '',
    this.phoneNumber = '',
    this.idType = 'National ID',
    this.idFrontUrl,
    this.idBackUrl,
    this.selfieUrl,
  });

  final VerificationType verificationType;
  final String legalName;
  final String phoneNumber;
  final String idType;
  final String? idFrontUrl;
  final String? idBackUrl;
  final String? selfieUrl;

  bool get hasLegalName => legalName.trim().isNotEmpty;
  bool get hasPhoneNumber => phoneNumber.trim().isNotEmpty;
  bool get hasPersonalDetails => hasLegalName && hasPhoneNumber;
  bool get hasFront => idFrontUrl?.trim().isNotEmpty ?? false;
  bool get hasBack => idBackUrl?.trim().isNotEmpty ?? false;
  bool get hasSelfie => selfieUrl?.trim().isNotEmpty ?? false;
  bool get hasProgress =>
      hasLegalName ||
      hasPhoneNumber ||
      idType != 'National ID' ||
      hasFront ||
      hasBack ||
      hasSelfie;

  factory UserVerificationDraft.fromJson(Map<String, dynamic> json) {
    final idType = asNullableString(json['id_type'])?.trim();

    return UserVerificationDraft(
      verificationType: VerificationType.fromApiValue(
        json['verification_type'],
        fallback: VerificationType.individual,
      ),
      legalName: asNullableString(json['legal_name'])?.trim() ?? '',
      phoneNumber: asNullableString(json['phone_number'])?.trim() ?? '',
      idType: idType == null || idType.isEmpty ? 'National ID' : idType,
      idFrontUrl: asNullableString(json['id_front']),
      idBackUrl: asNullableString(json['id_back']),
      selfieUrl: asNullableString(json['selfie']),
    );
  }

  UserVerificationDraft copyWith({
    VerificationType? verificationType,
    String? legalName,
    String? phoneNumber,
    String? idType,
    String? idFrontUrl,
    String? idBackUrl,
    String? selfieUrl,
  }) {
    return UserVerificationDraft(
      verificationType: verificationType ?? this.verificationType,
      legalName: legalName ?? this.legalName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      idType: idType ?? this.idType,
      idFrontUrl: idFrontUrl ?? this.idFrontUrl,
      idBackUrl: idBackUrl ?? this.idBackUrl,
      selfieUrl: selfieUrl ?? this.selfieUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'verification_type': verificationType.apiValue,
      'legal_name': legalName,
      'phone_number': phoneNumber,
      'id_type': idType,
      'id_front': idFrontUrl,
      'id_back': idBackUrl,
      'selfie': selfieUrl,
    };
  }

  Map<String, dynamic> toPayload() {
    return {
      'verification_type': verificationType.apiValue,
      'legal_name': legalName.trim(),
      'phone_number': phoneNumber.trim().replaceAll(RegExp(r'[\s()\-]'), ''),
      'verification_documents': [
        if (hasFront)
          {
            'document_type': 'id_front',
            'media': idFrontUrl,
            'media_id': idFrontUrl,
          },
        if (hasBack)
          {
            'document_type': 'id_back',
            'media': idBackUrl,
            'media_id': idBackUrl,
          },
        if (hasSelfie)
          {
            'document_type': 'selfie',
            'media': selfieUrl,
            'media_id': selfieUrl,
          },
      ],
    };
  }
}

class UserVerificationState {
  const UserVerificationState({
    this.draft = const UserVerificationDraft(),
    this.currentStep = 0,
    this.completedSteps = const <int>{},
    this.isRestoringDraft = false,
    this.isUploadingFront = false,
    this.isUploadingBack = false,
    this.isUploadingSelfie = false,
    this.isSubmitting = false,
  });

  final UserVerificationDraft draft;
  final int currentStep;
  final Set<int> completedSteps;
  final bool isRestoringDraft;
  final bool isUploadingFront;
  final bool isUploadingBack;
  final bool isUploadingSelfie;
  final bool isSubmitting;

  bool get isBusy =>
      isRestoringDraft ||
      isUploadingFront ||
      isUploadingBack ||
      isUploadingSelfie ||
      isSubmitting;

  UserVerificationState copyWith({
    UserVerificationDraft? draft,
    int? currentStep,
    Set<int>? completedSteps,
    bool? isRestoringDraft,
    bool? isUploadingFront,
    bool? isUploadingBack,
    bool? isUploadingSelfie,
    bool? isSubmitting,
  }) {
    return UserVerificationState(
      draft: draft ?? this.draft,
      currentStep: currentStep ?? this.currentStep,
      completedSteps: completedSteps ?? this.completedSteps,
      isRestoringDraft: isRestoringDraft ?? this.isRestoringDraft,
      isUploadingFront: isUploadingFront ?? this.isUploadingFront,
      isUploadingBack: isUploadingBack ?? this.isUploadingBack,
      isUploadingSelfie: isUploadingSelfie ?? this.isUploadingSelfie,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}
