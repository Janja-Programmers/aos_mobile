import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/features/auth/data/auth_api.dart';

typedef AuthApiResponse = Either<Failure, Map<String, dynamic>>;
typedef LoginHandler =
    Future<AuthApiResponse> Function(String identifier, String password);
typedef NoArgumentAuthHandler = Future<AuthApiResponse> Function();

class ScriptedAuthApi extends AuthApi {
  ScriptedAuthApi(
    super.client, {
    LoginHandler? loginHandler,
    NoArgumentAuthHandler? meHandler,
    NoArgumentAuthHandler? logoutHandler,
  }) : loginHandler = loginHandler ?? _unexpectedLogin,
       meHandler = meHandler ?? _unexpectedNoArgumentCall,
       logoutHandler = logoutHandler ?? _successfulLogout;

  LoginHandler loginHandler;
  NoArgumentAuthHandler meHandler;
  NoArgumentAuthHandler logoutHandler;

  int loginCalls = 0;
  int meCalls = 0;
  int logoutCalls = 0;
  String? lastIdentifier;
  String? lastPassword;

  @override
  Future<AuthApiResponse> login({
    required String identifier,
    required String password,
  }) async {
    loginCalls++;
    lastIdentifier = identifier;
    lastPassword = password;
    return loginHandler(identifier, password);
  }

  @override
  Future<AuthApiResponse> me() async {
    meCalls++;
    return meHandler();
  }

  @override
  Future<AuthApiResponse> logout() async {
    logoutCalls++;
    return logoutHandler();
  }

  static Future<AuthApiResponse> _unexpectedLogin(
    String identifier,
    String password,
  ) async {
    return Either<Failure, Map<String, dynamic>>.left(
      const Failure('Unexpected test login call.'),
    );
  }

  static Future<AuthApiResponse> _unexpectedNoArgumentCall() async {
    return Either<Failure, Map<String, dynamic>>.left(
      const Failure('Unexpected test API call.'),
    );
  }

  static Future<AuthApiResponse> _successfulLogout() async {
    return Either<Failure, Map<String, dynamic>>.right(<String, dynamic>{
      'ok': true,
      'data': <String, dynamic>{},
    });
  }
}
