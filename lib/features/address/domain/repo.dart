import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';

import 'address.dart';

abstract class AddressRepository {
  /// Create a new address remotely
  Future<Either<Failure, String>> createShippingAddress(Address address);

  /// Update an existing address remotely
  Future<Either<Failure, bool>> updateShippingAddress(Address address);

  /// Fetch all shipping addresses remotely
  Future<Either<Failure, List<Address>>> fetchShippingAddresses();

  /// Delete an address remotely
  Future<Either<Failure, bool>> deleteShippingAddress(String addressName);
}
