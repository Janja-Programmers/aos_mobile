import 'package:africaonlinestores/core/utils/json_utils.dart';

import '../../../helpers/fixture_loader.dart';

const String _accountProfileFixtureDirectory =
    'test/features/account_profile/fixtures';

Future<Map<String, dynamic>> loadAccountProfileMessageFixture(
  String filename,
) async {
  final Map<String, dynamic> root = await loadJsonObjectFixture(
    filename,
    baseDirectory: _accountProfileFixtureDirectory,
  );
  return asJsonMap(root['message']);
}

Future<Map<String, dynamic>> loadAccountProfileDataFixture(
  String filename,
) async {
  final Map<String, dynamic> message = await loadAccountProfileMessageFixture(
    filename,
  );
  return asJsonMap(message['data']);
}
