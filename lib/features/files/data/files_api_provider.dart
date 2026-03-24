import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/providers.dart';

import 'package:africaonlinestores/features/files/data/files_api.dart';

final filesApiProvider = Provider<FilesApi>((ref) {
  return FilesApi(ref.read(apiClientProvider));
});
