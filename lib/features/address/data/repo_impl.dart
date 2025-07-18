import 'package:dartz/dartz.dart';
import 'package:ownashop/core/errors/exception.dart';
import 'package:ownashop/core/utils/logger.dart';

import '/core/errors/failures.dart';

import '../domain/address.dart';
import '../domain/repo.dart';

import 'datasource/local.dart';
import 'datasource/remote.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressRemoteDatasource remote;
  final LocalAddressRepository local;

  AddressRepositoryImpl({required this.remote, required this.local});

  @override
  Future<Either<Failure, String>> createShippingAddress(Address address) async {
    try {
      final created = await remote.createAddress(address);
      appLogger.i('Address from authrepoimpl: ${created.title}');

      // 🔁 Update the cart with the new shipping address
      await remote.updateCartShippingAddress(created.name);

      await local.insertShippingAddress(created);
      appLogger.i('Address saved locally: ${created.title}');
      appLogger.i('Address created: ${created.name}');

      return Right(created.name);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Address>>> fetchShippingAddresses() async {
    try {
      final list = await local.getAllShippingAddresses();
      return Right(list);
    } catch (e) {
      return Left(handleException("Shipping addresses fetch failed"));
    }
  }
}
