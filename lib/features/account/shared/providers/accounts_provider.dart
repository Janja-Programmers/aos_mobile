import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/features/account/data/accounts_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final accountsApiProvider = Provider<AccountsApi>((ref) {
  return AccountsApi(ref.watch(apiClientProvider));
});
