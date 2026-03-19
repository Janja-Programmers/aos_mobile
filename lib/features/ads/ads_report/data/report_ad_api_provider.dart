import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/features/ads/ads_report/data/report_ad_api.dart';

final reportAdApiProvider = Provider<ReportAdApi>((ref) {
  final client = ref.read(apiClientProvider);
  return ReportAdApi(client);
});
