import '/core/utils/api_client.dart';

class VendorUtils {
  final APIClient client;
  VendorUtils(this.client);

  Future<VendorDetails?> fetchVendor(String vendorName) async {
    try {
      final res = await client.client.post(
        '/api/method/aos.overrides.item.get_supplier_details',
        data: {"vendor_name": vendorName},
      );

      final data = res.data['message'];
      if (data == null) {
        return null;
      }

      return VendorDetails(
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        phone: data['phone'] ?? '',
      );
    } catch (e) {
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
