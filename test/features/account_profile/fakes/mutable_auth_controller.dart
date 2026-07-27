import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller.dart';

class MutableAuthController extends AuthController {
  MutableAuthController({
    required super.ref,
    required super.api,
    required super.apiClient,
    required super.storage,
    required AuthState initialState,
  }) {
    state = initialState;
  }

  void replace(AuthState next) => state = next;
}
