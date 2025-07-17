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

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? fullName,
    String? userType,
    String? phone,
    String? password,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      userType: userType ?? this.userType,
      phone: phone ?? this.phone,
      password: password ?? this.password,
    );
  }
}

class LoginResult {
  final User user;
  final String homePage;

  LoginResult({required this.user, required this.homePage});
}
