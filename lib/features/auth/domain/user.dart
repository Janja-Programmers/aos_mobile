class User {
  final int? id;
  final String username;
  final String? email;
  final String? fullName;
  final String? userType;
  final String? phone;
  final String? password;

  User({
    this.id,
    required this.username,
    this.email,
    this.fullName,
    this.userType,
    this.phone,
    this.password,
  });
}
