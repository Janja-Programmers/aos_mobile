import 'package:ownashop/core/utils/logger.dart';

import '/core/constants/const.dart';
import '/core/utils/api_client.dart';

import '../../domain/address.dart';

import '../model.dart';

abstract class AddressRemoteDatasource {
  Future<String> createAddress(Address address);
}

class AddressRemoteDatasourceImpl implements AddressRemoteDatasource {
  final APIClient apiClient;

  AddressRemoteDatasourceImpl(this.apiClient);

  @override
  Future<String> createAddress(Address address) async {
    final model = AddressModel.fromEntity(address);

    final res = await apiClient.client.post(
      ADDRESS_ENDPOINT,
      data: model.toJson(),
    );

    final name = res.data['data']?['name'];
    if (name == null) throw Exception('Address creation failed');
    appLogger.i('Address created: $name');
    return name;
  }
}
