import 'package:dartz/dartz.dart';

import '/core/errors/exception.dart';
import '/core/errors/failures.dart';
import '/core/utils/logger.dart';

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
      appLogger.i('✅ Address created remotely: ${created.title}');

      await remote.updateCartShippingAddress(created.name);
      appLogger.i('🛒 Cart updated with shipping address: ${created.name}');

      return Right(created.name);
    } catch (e) {
      appLogger.e('❌ Failed to create shipping address: $e');
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
      appLogger.i('🔁 Address updated: ${address.name}');
      return const Right(true);
    } catch (e) {
      appLogger.e('❌ Failed to update address: $e');
      return Left(ServerFailure('Failed to update address'));
    }
  }

  @override
  Future<Either<Failure, List<Address>>> fetchShippingAddresses() async {
    try {
      final addresses = await remote.getAllShippingAddresses();
      appLogger.i('📦 ${addresses.length} address(es) fetched remotely');
      return Right(addresses);
    } catch (e) {
      appLogger.e('❌ Error fetching addresses: $e');
      return Left(handleException("Shipping addresses fetch failed"));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteShippingAddress(
    String addressName,
  ) async {
    try {
      await remote.deleteAddress(addressName);
      appLogger.i('🗑️ Address deleted: $addressName');
      return const Right(true);
    } catch (e) {
      appLogger.e('❌ Failed to delete address: $e');
      return Left(ServerFailure('Failed to delete address'));
    }
  }
}
