import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/ads/domain/ad_schema.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ads_api_provider.dart';

/// ------------------------------------------------------------
/// CATEGORY SCHEMA
/// ------------------------------------------------------------
/// Fetches category schema from backend.
/// Cached for a short duration to avoid repeated API calls
/// during multi-step ad creation flow.
final adCategorySchemaProvider =
    FutureProvider.family<AdCategorySchema, String>((ref, categoryId) async {
      // Keep provider alive during flow
      final link = ref.keepAlive();

      final timer = Timer(const Duration(minutes: 10), () {
        link.close();
      });

      ref.onDispose(() {
        timer.cancel();
      });

      final api = ref.read(adsApiProvider);

      final res = await api.getCategorySchema(categoryId: categoryId);

      return res.fold(
        (failure) {
          throw Exception(failure.message);
        },
        (payload) {
          final schema = AdCategorySchemaModel.fromPayload(payload);

          return schema;
        },
      );
    });
