import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/sellers/application/controllers/seller_state_controller.dart';
import 'package:africaonlinestores/features/sellers/application/controllers/storefront_dashboard_controller.dart';
import 'package:africaonlinestores/features/sellers/application/state/storefront_dashboard_state.dart';
import 'package:africaonlinestores/features/sellers/domain/aos_seller.dart';
import 'package:africaonlinestores/features/shorts/shared/application/providers/shorts_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final sellerProfileProvider = FutureProvider.family<AOSSellerProfile, String>((
  ref,
  sellerId,
) async {
  final controller = ref.read(sellerControllerProvider);

  final result = await controller.getSeller(sellerId: sellerId);

  return result.fold((failure) => throw Exception(failure.message), (data) {
    final message = asJsonMap(data['message']);
    final sellerJson = data['data'] ?? message['data'];

    if (sellerJson == null) {
      throw Exception('Seller data missing');
    }

    return AOSSellerProfile.fromJson(asJsonMap(sellerJson));
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
