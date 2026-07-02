import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/features/preferences/data/user_preference_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userPreferenceApiProvider = Provider<UserPreferenceApi>((ref) {
  return UserPreferenceApi(ref.watch(apiClientProvider));
});
