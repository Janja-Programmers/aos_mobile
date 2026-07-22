import 'package:africaonlinestores/core/utils/json_utils.dart';

import '../../../helpers/fixture_loader.dart';

const String _authFixtureDirectory =
    'test/features/authentication_session/fixtures';

Future<Map<String, dynamic>> loadAuthMessageFixture(String filename) async {
  final Map<String, dynamic> root = await loadJsonObjectFixture(
    filename,
    baseDirectory: _authFixtureDirectory,
  );
  return asJsonMap(root['message']);
}
