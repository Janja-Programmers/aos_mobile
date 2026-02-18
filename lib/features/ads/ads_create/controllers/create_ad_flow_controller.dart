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

  void reset() {
    state = state.reset();
  }
}
