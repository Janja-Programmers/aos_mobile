import '../domain/user.dart';

class UserModel extends User {
  UserModel({super.id, required super.username, required super.password});

  factory UserModel.fromMap(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    username: json['username'],
    password: json['password'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'username': username,
    'password': password,
  };
}
