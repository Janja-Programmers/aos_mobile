import 'package:equatable/equatable.dart';

class ShortCreator extends Equatable {
  final String user;
  final String displayName;
  final String? avatar;
  final bool isVerified;
  final bool isLive;
  final String? liveId;
  final String? liveStatus;
  final ShortCreatorSeller? seller;

  const ShortCreator({
    required this.user,
    required this.displayName,
    this.avatar,
    required this.isVerified,
    this.isLive = false,
    this.liveId,
    this.liveStatus,
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
    bool? isLive,
    String? liveId,
    String? liveStatus,
    ShortCreatorSeller? seller,
  }) {
    return ShortCreator(
      user: user ?? this.user,
      displayName: displayName ?? this.displayName,
      avatar: avatar ?? this.avatar,
      isVerified: isVerified ?? this.isVerified,
      isLive: isLive ?? this.isLive,
      liveId: liveId ?? this.liveId,
      liveStatus: liveStatus ?? this.liveStatus,
      seller: seller ?? this.seller,
    );
  }

  @override
  List<Object?> get props => [
    user,
    displayName,
    avatar,
    isVerified,
    isLive,
    liveId,
    liveStatus,
    seller,
  ];
}

class ShortCreatorSeller extends Equatable {
  final String id;

  const ShortCreatorSeller({required this.id});

  @override
  List<Object?> get props => [id];
}
