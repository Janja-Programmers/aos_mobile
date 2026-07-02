import 'package:equatable/equatable.dart';

class ShortCreator extends Equatable {
  final String user;
  final String displayName;
  final String? avatar;
  final bool isVerified;
  final ShortCreatorSeller? seller;

  const ShortCreator({
    required this.user,
    required this.displayName,
    this.avatar,
    required this.isVerified,
    this.seller,
  });

  factory ShortCreator.empty() {
    return const ShortCreator(user: '', displayName: '', isVerified: false);
  }

  String get sellerId => seller?.id ?? user;

  ShortCreator copyWith({
    String? user,
    String? displayName,
    String? avatar,
    bool? isVerified,
    ShortCreatorSeller? seller,
  }) {
    return ShortCreator(
      user: user ?? this.user,
      displayName: displayName ?? this.displayName,
      avatar: avatar ?? this.avatar,
      isVerified: isVerified ?? this.isVerified,
      seller: seller ?? this.seller,
    );
  }

  @override
  List<Object?> get props => [user, displayName, avatar, isVerified, seller];
}

class ShortCreatorSeller extends Equatable {
  final String id;

  const ShortCreatorSeller({required this.id});

  @override
  List<Object?> get props => [id];
}
