import 'package:flutter/foundation.dart';

@immutable
class ProfileUpdateRequest {
  const ProfileUpdateRequest({
    this.fullName,
    this.bio,
    this.userImage,
    this.userImageMedia,
  });

  static const int fullNameMinLength = 2;
  static const int fullNameMaxLength = 80;
  static const int bioMaxLength = 300;

  final String? fullName;
  final String? bio;
  final String? userImage;
  final String? userImageMedia;

  String? get fullNameValidationMessage {
    if (fullName == null) return null;

    final String value = fullName!.trim();
    if (value.isEmpty) return 'Full name is required.';
    if (value.length < fullNameMinLength) return 'Full name is too short.';
    if (value.length > fullNameMaxLength) return 'Full name is too long.';
    return null;
  }

  String? get bioValidationMessage {
    if (bio == null) return null;

    if (bio!.trim().length > bioMaxLength) {
      return 'Bio is too long. Maximum is $bioMaxLength characters.';
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (fullName != null) 'full_name': _normalizeWhitespace(fullName!),
      if (bio != null) 'bio': _normalizeBio(bio!),
      if (userImage != null) 'user_image': userImage!.trim(),
      if (userImageMedia != null) 'profile_image_media': userImageMedia!.trim(),
    };
  }

  static String _normalizeWhitespace(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static String _normalizeBio(String value) {
    return value
        .trim()
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n');
  }
}
