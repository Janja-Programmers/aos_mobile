import 'address.dart';

abstract class AddressRepository {
  Future<String> createShippingAddress(Address address);
  Future<List<Address>> fetchShippingAddresses();
}
