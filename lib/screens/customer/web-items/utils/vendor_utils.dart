import '/core/utils/api_client.dart';

class VendorUtils {
  final APIClient client;
  VendorUtils(this.client);

  Future<VendorDetails?> fetchVendor(String vendorName) async {
    try {
      print('✅ VendorName: $vendorName');

      final res = await client.client.post(
        '/api/method/amani_mall.overrides.item.get_supplier_details',
        data: {"vendor_name": vendorName},
      );

      print('✅ API Response: ${res.data}');

      final data = res.data['message'];
      if (data == null) {
        print('⚠️ No "message" field in response');
        return null;
      }

      print('✅ Vendor data: $data');

      return VendorDetails(
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        phone: data['phone'] ?? '',
      );
    } catch (e) {
      print('❌ Error fetching vendor: $e');
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
