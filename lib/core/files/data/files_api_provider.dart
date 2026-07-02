import 'package:africaonlinestores/core/files/data/files_api.dart';
import 'package:africaonlinestores/core/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final filesApiProvider = Provider<FilesApi>((ref) {
  return FilesApi(ref.read(apiClientProvider));
});
