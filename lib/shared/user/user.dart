class User {
  final String id;
  final String email;
  final String fullName;
  final String? firstName;
  final String? lastName;
  final String? avatarUrl;
  final bool isActive;
  final bool isVerified;
  final String? country;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    this.firstName,
    this.lastName,
    this.avatarUrl,
    required this.isActive,
    this.isVerified = false,
    this.country,
  });

  /// Convenience
  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;

  /// Initials fallback (for UI)
  String get initials {
    if (fullName.isEmpty) return '';
    final parts = fullName.trim().split(' ');
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

/// Model (DTO / Mapper)
class UserModel {
  /// Maps Frappe User → User
  static User fromMap(Map<String, dynamic> map) {
    final name = (map['name'] ?? '').toString();

    return User(
      id: name,
      email: (map['email'] ?? name).toString(),
      fullName: (map['full_name'] ?? '').toString(),
      firstName: map['first_name']?.toString(),
      lastName: map['last_name']?.toString(),
      avatarUrl: map['user_image']?.toString(),
      isActive: (map['enabled'] ?? 1) == 1,
      isVerified: (map['is_verified'] ?? 0) == 1, // future-proof
      country: map['country']?.toString(),
    );
  }
}
