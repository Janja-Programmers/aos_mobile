import '../domain/address.dart';
import '../domain/repo.dart';

import 'datasource/local.dart';
import 'datasource/remote.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressRemoteDatasource remote;
  final LocalAddressRepository local;

  AddressRepositoryImpl({required this.remote, required this.local});

  @override
  Future<String> createShippingAddress(Address address) async {
    final name = await remote.createAddress(address);
    await local.insertShippingAddress(address);
    return name;
  }

  @override
  Future<List<Address>> fetchShippingAddresses() async {
    return await local.getAllShippingAddresses();
  }
}

