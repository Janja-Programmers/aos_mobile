import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/features/ads/ads_form/controllers/ad_form_state.dart';
import 'package:africaonlinestores/shared/enums/ads.dart';

final adFormControllerProvider = StateNotifierProvider.autoDispose
    .family<AdFormController, AdFormState, AdFormMode>(
      (ref, mode) => AdFormController(mode: mode),
    );

class AdFormController extends StateNotifier<AdFormState> {
  final AdFormMode mode;
  final String? adId;

  AdFormController({required this.mode, this.adId})
    : super(const AdFormState());

  void goBack() {
    if (state.index > 0) {
      state = state.copyWith(index: state.index - 1);
    }
  }

  void setIndex(int i) {
    if (i < 0) return;
    state = state.copyWith(index: i);
  }

  void startPosting() {
    state = state.copyWith(posting: true);
  }

  void stopPosting() {
    state = state.copyWith(posting: false);
  }

  void markCompleted(int i) {
    final updated = {...state.completed, i};
    state = state.copyWith(completed: updated);
  }

  int get furthestReachableStep {
    if (state.completed.isEmpty) return 0;
    final maxCompleted = state.completed.reduce((a, b) => a > b ? a : b);
    return maxCompleted + 1;
  }

  bool canNavigateTo(int index) {
    if (state.posting) return false;
    return index <= furthestReachableStep;
  }

  void markAttempted(int i) {
    final updated = {...state.attempted, i};
    state = state.copyWith(attempted: updated);
  }

  void reset() {
    state = state.reset();
  }
}
