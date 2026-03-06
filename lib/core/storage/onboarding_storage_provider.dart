import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/storage/onboarding_storage.dart';

final onboardingStorageProvider = Provider<OnboardingStorage>((ref) {
  throw UnimplementedError("Provide SharedPreferences binding in bootstrap.");
});
