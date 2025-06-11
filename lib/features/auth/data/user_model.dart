import '../domain/user.dart';

class UserModel extends User {
  UserModel({
    super.id,
    required super.username,
    super.email,
    super.fullName,
    super.userType,
    super.phone,
    super.password,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    username: json['username'],
    email: json['email'],
    fullName: json['full_name'],
    userType: json['user_type'],
    phone: json['phone'],
    password: json['password'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'full_name': fullName,
    'user_type': userType,
    'phone': phone,
    'password': password,
  };
}
