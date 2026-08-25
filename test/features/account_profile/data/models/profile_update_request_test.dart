import 'package:africaonlinestores/features/account/domain/profile_update_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProfileUpdateRequest', () {
    test('serializes only backend-supported fields', () {
      const ProfileUpdateRequest request = ProfileUpdateRequest(
        fullName: ' Test   Owner ',
        bio: ' First line.  \n\n\n Second line. ',
        userImageMedia: ' MEDIA-TEST-001 ',
      );

      expect(request.toJson(), <String, dynamic>{
        'full_name': 'Test Owner',
        'bio': 'First line. \n\n Second line.',
        'avatar_media_id': 'MEDIA-TEST-001',
      });
      expect(request.toJson().containsKey('display_name'), isFalse);
      expect(request.toJson().containsKey('email'), isFalse);
      expect(request.toJson().containsKey('phone'), isFalse);
    });

    test('maps empty legacy avatar value to remove_avatar', () {
      const ProfileUpdateRequest request = ProfileUpdateRequest(userImage: '');

      expect(request.avatarValidationMessage, isNull);
      expect(request.toJson(), <String, dynamic>{'remove_avatar': true});
    });

    test('rejects an empty avatar media ID', () {
      const ProfileUpdateRequest request = ProfileUpdateRequest(
        userImageMedia: ' ',
      );

      expect(request.avatarValidationMessage, 'Avatar media ID is required.');
      expect(request.toJson(), isEmpty);
    });

    test('rejects combined avatar replacement and removal', () {
      const ProfileUpdateRequest request = ProfileUpdateRequest(
        userImage: '',
        userImageMedia: 'MEDIA-TEST-001',
      );

      expect(
        request.avatarValidationMessage,
        'Avatar replacement and removal cannot be combined.',
      );
    });

    test('omits unchanged nullable fields', () {
      const ProfileUpdateRequest request = ProfileUpdateRequest(bio: 'Bio');

      expect(request.toJson(), <String, dynamic>{'bio': 'Bio'});
    });

    test('accepts backend full-name boundaries', () {
      const ProfileUpdateRequest minimum = ProfileUpdateRequest(fullName: 'AB');
      final ProfileUpdateRequest maximum = ProfileUpdateRequest(
        fullName: List<String>.filled(
          ProfileUpdateRequest.fullNameMaxLength,
          'A',
        ).join(),
      );

      expect(minimum.fullNameValidationMessage, isNull);
      expect(maximum.fullNameValidationMessage, isNull);
    });

    test('rejects empty, short, and overlong full names', () {
      expect(
        const ProfileUpdateRequest(fullName: ' ').fullNameValidationMessage,
        'Full name is required.',
      );
      expect(
        const ProfileUpdateRequest(fullName: 'A').fullNameValidationMessage,
        'Full name is too short.',
      );
      expect(
        ProfileUpdateRequest(
          fullName: List<String>.filled(
            ProfileUpdateRequest.fullNameMaxLength + 1,
            'A',
          ).join(),
        ).fullNameValidationMessage,
        'Full name is too long.',
      );
    });

    test('accepts 500-character bio and rejects 501 characters', () {
      expect(
        ProfileUpdateRequest(
          bio: List<String>.filled(
            ProfileUpdateRequest.bioMaxLength,
            'A',
          ).join(),
        ).bioValidationMessage,
        isNull,
      );
      expect(
        ProfileUpdateRequest(
          bio: List<String>.filled(
            ProfileUpdateRequest.bioMaxLength + 1,
            'A',
          ).join(),
        ).bioValidationMessage,
        contains('Maximum is 500'),
      );
    });
  });
}
