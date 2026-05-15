import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:africaonlinestores/features/sellers/application/controllers/seller_state_controller.dart';
import 'package:africaonlinestores/features/sellers/application/controllers/storefront_dashboard_controller.dart';
import 'package:africaonlinestores/features/sellers/application/state/storefront_dashboard_state.dart';
import 'package:africaonlinestores/features/sellers/domain/aos_seller.dart';

import 'package:africaonlinestores/features/shorts/shared/application/providers/shorts_providers.dart';

final sellerProfileProvider = FutureProvider.family<AOSSellerProfile, String>((
  ref,
  sellerId,
) async {
  final controller = ref.read(sellerControllerProvider);

  final result = await controller.getSeller(sellerId: sellerId);

  return result.fold((failure) => throw Exception(failure.message), (data) {
    // 🔥 handle both cases safely
    final sellerJson = data['data'] ?? data['message']?['data'];

    if (sellerJson == null) {
      throw Exception("Seller data missing");
    }

    return AOSSellerProfile.fromJson(Map<String, dynamic>.from(sellerJson));
  });
});

final storefrontDashboardControllerProvider =
    StateNotifierProvider<
      StorefrontDashboardController,
      StorefrontDashboardState
    >((ref) {
      return StorefrontDashboardController(
        shortsManagementApi: ref.read(shortsManagementApiProvider),
      );
    });
