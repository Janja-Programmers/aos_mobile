import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/features/account/data/accounts_api.dart';

class ProfileUpdateCall {
  const ProfileUpdateCall({
    this.fullName,
    this.userImage,
    this.userImageMedia,
    this.bio,
  });

  final String? fullName;
  final String? userImage;
  final String? userImageMedia;
  final String? bio;
}

typedef GetProfileHandler =
    Future<Either<Failure, Map<String, dynamic>>> Function(String? targetUser);
typedef UpdateProfileHandler =
    Future<Either<Failure, Map<String, dynamic>>> Function(
      ProfileUpdateCall call,
    );

class ScriptedAccountsApi extends AccountsApi {
  ScriptedAccountsApi(
    super.client, {
    this.getProfileHandler,
    this.updateProfileHandler,
  });

  final GetProfileHandler? getProfileHandler;
  final UpdateProfileHandler? updateProfileHandler;

  int getProfileCalls = 0;
  int updateProfileCalls = 0;
  final List<String?> requestedTargets = <String?>[];
  final List<ProfileUpdateCall> updateCalls = <ProfileUpdateCall>[];

  @override
  Future<Either<Failure, Map<String, dynamic>>> getProfile({
    String? targetUser,
  }) async {
    getProfileCalls += 1;
    requestedTargets.add(targetUser);
    final GetProfileHandler? handler = getProfileHandler;
    if (handler != null) return handler(targetUser);
    return Either.left(const Failure('No profile response configured.'));
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> updateProfile({
    String? fullName,
    String? userImage,
    String? userImageMedia,
    String? bio,
  }) async {
    updateProfileCalls += 1;
    final ProfileUpdateCall call = ProfileUpdateCall(
      fullName: fullName,
      userImage: userImage,
      userImageMedia: userImageMedia,
      bio: bio,
    );
    updateCalls.add(call);
    final UpdateProfileHandler? handler = updateProfileHandler;
    if (handler != null) return handler(call);
    return Either.left(const Failure('No update response configured.'));
  }
}
