import 'package:ownashop/core/utils/logger.dart';
import '/core/utils/api_client.dart';

class VendorUtils {
  final APIClient client;
  VendorUtils(this.client);

  Future<VendorDetails?> fetchVendor(String vendorName) async {
    try {
      final res = await client.client.get(
        '/api/method/amani_mall.overrides.item.get_supplier_details',
        queryParameters: {"vendor_name": vendorName},
      );

      final data = res.data['message'];
      return VendorDetails(
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        phone: data['phone'] ?? '',
      );
    } catch (e) {
      appLogger.e('Vendor fetch error', error: e);

      return null;
    }
  }
}

class VendorDetails {
  final String name;
  final String email;
  final String phone;

  VendorDetails({required this.name, required this.email, required this.phone});
}
