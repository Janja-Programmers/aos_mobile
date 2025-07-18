import '/core/constants/const.dart';
import '/core/utils/api_client.dart';

import '../../domain/address.dart';

import '../model.dart';

abstract class AddressRemoteDatasource {
  Future<Address> createAddress(Address address);
  Future<void> updateCartShippingAddress(String addressName);
}

class AddressRemoteDatasourceImpl implements AddressRemoteDatasource {
  final APIClient apiClient;

  AddressRemoteDatasourceImpl(this.apiClient);

  @override
  Future<Address> createAddress(Address address) async {
    final model = AddressModel.fromEntity(address);

    final payload = {"doc": model.toJson()};

    final res = await apiClient.client.post(ApiRoutes.address, data: payload);

    final data = res.data['message'];
    if (data == null) throw Exception('Address creation failed');

    final created = AddressModel.fromMap(data).toEntity();

    return created;
  }

  @override
  Future<void> updateCartShippingAddress(String addressName) async {
    final payload = {"address_type": "Shipping", "address_name": addressName};

    await apiClient.client.post(ApiRoutes.updateCart, data: payload);
  }
}
