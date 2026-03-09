import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/storage/onboarding_storage.dart';

final onboardingStorageProvider = Provider<OnboardingStorage>((ref) {
  throw UnimplementedError(
    "OnboardingStorage must be provided during app bootstrap.",
  );
});
