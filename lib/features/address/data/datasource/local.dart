import 'package:sqflite/sqflite.dart';
import 'package:ownashop/core/db/db_helper.dart';
import '../../domain/address.dart';
import '../model.dart';

class LocalAddressRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Insert a new shipping address (or update existing)
  Future<void> insertShippingAddress(Address address) async {
    final db = await _dbHelper.database;
    final model = AddressModel.fromEntity(address);

    await db.insert(
      'address',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all stored shipping addresses
  Future<List<Address>> getAllShippingAddresses() async {
    final db = await _dbHelper.database;

    final result = await db.query('address');

    return result.map((row) => AddressModel.fromMap(row).toEntity()).toList();
  }

  Future<List<Address>> getAddressesForCustomer(String customer) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'address',
      where: 'customer = ?',
      whereArgs: [customer],
    );

    return result.map((e) => AddressModel.fromMap(e).toEntity()).toList();
  }
}
