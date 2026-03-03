import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/features/ads/ads_create/controllers/create_ad_flow_state.dart';

final createAdFlowControllerProvider =
    StateNotifierProvider<CreateAdFlowController, CreateAdFlowState>(
      (ref) => CreateAdFlowController(),
    );

class CreateAdFlowController extends StateNotifier<CreateAdFlowState> {
  CreateAdFlowController() : super(const CreateAdFlowState());

  void goBack() {
    if (state.index > 0) {
      state = state.copyWith(index: state.index - 1);
    }
  }

  void setIndex(int i) {
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
    if (index <= furthestReachableStep) return true;
    return false;
  }

  void markAttempted(int i) {
    final updated = {...state.attempted, i};
    state = state.copyWith(attempted: updated);
  }

  void reset() {
    state = state.reset();
  }
}
