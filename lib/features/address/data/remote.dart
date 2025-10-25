
import '/core/constants/const.dart';
import '/core/di/service_locator.dart';
import '/core/utils/api_client.dart';

import '/screens/auth/auth_provider.dart';
import '../domain/address.dart';
import 'model.dart';

abstract class AddressRemoteDatasource {
  Future<Address> createAddress(Address address);
  Future<void> updateAddress(Address address);
  Future<List<Address>> getAllShippingAddresses();
  Future<void> deleteAddress(String addressName);
  Future<void> updateCartShippingAddress(String addressName);
}

class AddressRemoteDatasourceImpl implements AddressRemoteDatasource {
  final APIClient apiClient;

  AddressRemoteDatasourceImpl(this.apiClient);

  @override
  Future<Address> createAddress(Address address) async {
    final model = AddressModel.fromEntity(address);
    final payload = {"doc": model.toJson()};

    final res = await apiClient.client.post(
      ApiRoutes.newAddress,
      data: payload,
    );
    final data = res.data['message'];

    if (data == null) throw Exception('Address creation failed');

    return AddressModel.fromMap(data).toEntity();
  }

  @override
  Future<void> updateAddress(Address address) async {
    final model = AddressModel.fromEntity(address);

    final payload = {...model.toJson(), 'name': address.name};

    try {
      await apiClient.client.put(
        '${ApiRoutes.address}/${address.name}',
        data: payload,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Address>> getAllShippingAddresses() async {
    final auth = sl<AuthProvider>(); // ✅ Moved inside the method
    final ownerEmail = auth.user?.email;

    if (ownerEmail == null) {
      throw Exception('User not authenticated');
    }

    final res = await apiClient.client.get(
      ApiRoutes.address,
      queryParameters: {
        'filters': '[["address_type","=","Shipping"]]',
        'fields':
            '["name","address_title","address_line1","city","country","phone","address_type","owner"]',
        'limit_page_length': 50,
      },
    );

    final data = res.data['data'] ?? [];

    final addresses =
        List<Map<String, dynamic>>.from(data)
            .where((json) => json['owner'] == ownerEmail)
            .map((json) => AddressModel.fromMap(json).toEntity())
            .toList();

    return addresses;
  }

  @override
  Future<void> deleteAddress(String addressName) async {
    await apiClient.client.delete('${ApiRoutes.address}/$addressName');
  }

  @override
  Future<void> updateCartShippingAddress(String addressName) async {
    final payload = {"address_type": "Shipping", "address_name": addressName};

    await apiClient.client.post(ApiRoutes.updateCart, data: payload);
  }
}
