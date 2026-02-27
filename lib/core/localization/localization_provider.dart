import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/localization/localization_controller.dart';
import 'package:africaonlinestores/core/localization/localization_state.dart';
import 'package:africaonlinestores/features/localization/data/localization_api.dart';

final localizationApiProvider = Provider<LocalizationApi>((ref) {
  return LocalizationApi(ref.watch(apiClientProvider));
});

final localizationControllerProvider =
    AsyncNotifierProvider<LocalizationController, LocalizationState>(
      LocalizationController.new,
    );
