import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/features/sellers/application/controllers/seller_state.dart';
import 'package:africaonlinestores/features/sellers/application/controllers/seller_state_controller.dart';

/// FINAL sellerStateProvider
final sellerStateProvider =
    StateNotifierProvider.family<SellerStateController, SellerState, String>((
      ref,
      sellerId,
    ) {
      return SellerStateController(ref, sellerId);
    });
