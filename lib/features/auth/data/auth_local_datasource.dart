import 'package:sqflite/sqflite.dart';
import '../../../core/db/db_helper.dart';
import 'user_model.dart';

class AuthLocalDataSource {
  late final Future<Database> _dbFuture;

  AuthLocalDataSource() {
    _dbFuture = DatabaseHelper().database;
  }

  Future<UserModel?> login(String username, String password) async {
    final db = await _dbFuture;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }
    return null;
  }

  Future<void> register(UserModel user) async {
    final db = await _dbFuture;
    await db.insert('users', user.toMap());
  }
}
