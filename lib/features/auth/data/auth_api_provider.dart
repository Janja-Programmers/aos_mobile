import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/features/auth/data/auth_api.dart';

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref.watch(apiClientProvider));
});
