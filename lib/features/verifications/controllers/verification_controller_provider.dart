import 'package:africaonlinestores/features/verifications/controllers/verification_controller.dart';
import 'package:africaonlinestores/features/verifications/controllers/verification_form_state.dart';
import 'package:flutter_riverpod/legacy.dart';

final sellerVerificationControllerProvider =
    StateNotifierProvider<
      SellerVerificationController,
      SellerVerificationState
    >((ref) => SellerVerificationController());
