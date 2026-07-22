import 'package:africaonlinestores/core/api/session_storage.dart';

class FakeSessionStorage extends SessionStorage {
  FakeSessionStorage({
    String? sid,
    bool rememberMe = true,
    String rememberedEmail = '',
  }) : _sid = sid,
       _rememberMe = rememberMe,
       _rememberedEmail = rememberedEmail;

  String? _sid;
  bool _rememberMe;
  String _rememberedEmail;

  @override
  Future<String?> getSid() async => _sid;

  @override
  Future<void> setSid(String sid) async {
    _sid = sid;
  }

  @override
  Future<void> clearSid() async {
    _sid = null;
  }

  @override
  Future<bool> getRememberMe() async => _rememberMe;

  @override
  Future<void> setRememberMe(bool remember) async {
    _rememberMe = remember;
  }

  @override
  Future<String> getRememberedEmail() async => _rememberedEmail;

  @override
  Future<void> setRememberedEmail(String email) async {
    _rememberedEmail = email;
  }

  @override
  Future<void> clearRememberedEmail() async {
    _rememberedEmail = '';
  }
}
