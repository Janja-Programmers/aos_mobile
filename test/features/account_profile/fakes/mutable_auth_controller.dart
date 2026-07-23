import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/api/session_storage.dart';
import 'package:africaonlinestores/features/auth/data/auth_api.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MutableAuthController extends AuthController {
  MutableAuthController({
    required Ref ref,
    required AuthApi api,
    required ApiClient apiClient,
    required SessionStorage storage,
    required AuthState initialState,
  }) : super(ref: ref, api: api, apiClient: apiClient, storage: storage) {
    state = initialState;
  }

  void replace(AuthState next) => state = next;
}
