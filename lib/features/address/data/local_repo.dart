import '/core/db/db_helper.dart';

import '../domain/address.dart';

import 'model.dart';

final DatabaseHelper _dbHelper = DatabaseHelper();

Future<List<Address>> getAllShippingAddresses() async {
  final db = await _dbHelper.database;

  final result = await db.query('address');

  return result.map((row) => AddressModel.fromMap(row).toEntity()).toList();
}
