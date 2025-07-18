import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';

import 'address.dart';

abstract class AddressRepository {
  /// Create address via remote then persist locally
  Future<Either<Failure, String>> createShippingAddress(Address address);

  /// Fetch all locally saved shipping addresses
  Future<Either<Failure, List<Address>>> fetchShippingAddresses();
}
