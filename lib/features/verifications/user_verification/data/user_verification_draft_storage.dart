import 'dart:convert';

import 'package:africaonlinestores/features/verifications/user_verification/domain/user_verification_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedUserVerificationDraft {
  const SavedUserVerificationDraft({
    required this.draft,
    required this.currentStep,
  });

  final UserVerificationDraft draft;
  final int currentStep;

  factory SavedUserVerificationDraft.fromJson(Map<String, dynamic> json) {
    final rawDraft = json['draft'];
    final draftJson = rawDraft is Map<String, dynamic>
        ? rawDraft
        : const <String, dynamic>{};

    return SavedUserVerificationDraft(
      draft: UserVerificationDraft.fromJson(draftJson),
      currentStep: _asInt(json['current_step']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': 1,
      'current_step': currentStep,
      'draft': draft.toJson(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
  }

  static int _asInt(Object? value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class UserVerificationDraftStorage {
  const UserVerificationDraftStorage();

  static const String _keyPrefix = 'aos.user_verification.draft.v1';

  Future<SavedUserVerificationDraft?> read(String userId) async {
    final preferences = await SharedPreferences.getInstance();
    final key = _keyFor(userId);
    final raw = preferences.getString(key);

    if (raw == null || raw.trim().isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        await preferences.remove(key);
        return null;
      }

      return SavedUserVerificationDraft.fromJson(decoded);
    } on FormatException {
      await preferences.remove(key);
      return null;
    }
  }

  Future<void> write({
    required String userId,
    required UserVerificationDraft draft,
    required int currentStep,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final savedDraft = SavedUserVerificationDraft(
      draft: draft,
      currentStep: currentStep,
    );

    await preferences.setString(
      _keyFor(userId),
      jsonEncode(savedDraft.toJson()),
    );
  }

  Future<void> clear(String userId) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_keyFor(userId));
  }

  String _keyFor(String userId) {
    final normalized = userId.trim().toLowerCase();
    final encoded = base64Url.encode(utf8.encode(normalized));
    return '$_keyPrefix.$encoded';
  }
}
