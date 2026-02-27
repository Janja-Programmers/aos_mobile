import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/preferences/data/user_preference_api.dart';
import 'package:africaonlinestores/core/preferences/user_preference_controller.dart';
import 'package:africaonlinestores/core/preferences/user_preference_state.dart';
import 'package:africaonlinestores/core/providers.dart';

final userPreferenceApiProvider = Provider<UserPreferenceApi>((ref) {
  return UserPreferenceApi(ref.watch(apiClientProvider));
});

final userPreferenceControllerProvider =
    AsyncNotifierProvider<UserPreferenceController, UserPreferenceState?>(
      UserPreferenceController.new,
    );
