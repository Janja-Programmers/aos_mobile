import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/features/ads/domain/ad_schema.dart';

final adCategorySchemaProvider = FutureProvider.family<AdCategorySchema, String>(
  (ref, categoryId) async {
    final api = ref.read(adsApiProvider);
    final res = await api.getCategorySchema(categoryId: categoryId);
    return res.fold(
      (f) => throw f,
      (p) => AdCategorySchema.fromBackendPayload(p),
    );
  },
);
