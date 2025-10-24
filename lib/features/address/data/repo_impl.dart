import 'package:dartz/dartz.dart';

import '/core/errors/exception.dart';
import '/core/errors/failures.dart';

import '../domain/address.dart';
import '../domain/repo.dart';

import 'remote.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressRemoteDatasource remote;

  AddressRepositoryImpl({required this.remote});

  @override
  Future<Either<Failure, String>> createShippingAddress(Address address) async {
    try {
      final created = await remote.createAddress(address);
      await remote.updateCartShippingAddress(created.name);
      return Right(created.name);
    } catch (e) {
      return Left(ServerFailure('Failed to create address'));
    }
  }

  @override
  Future<Either<Failure, bool>> updateShippingAddress(Address address) async {
    try {
      if (address.name.isEmpty) {
        throw Exception('Address name is required for update');
      }
      await remote.updateAddress(address);
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure('Failed to update address'));
    }
  }

  @override
  Future<Either<Failure, List<Address>>> fetchShippingAddresses() async {
    try {
      final addresses = await remote.getAllShippingAddresses();
      return Right(addresses);
    } catch (e) {
      return Left(handleException("Shipping addresses fetch failed"));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteShippingAddress(
    String addressName,
  ) async {
    try {
      await remote.deleteAddress(addressName);
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure('Failed to delete address'));
    }
  }
}
