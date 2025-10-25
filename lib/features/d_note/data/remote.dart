import 'package:dartz/dartz.dart';

import '/core/constants/const.dart';
import '/core/errors/exception.dart';
import '/core/errors/failures.dart';
import '/core/utils/api_client.dart';

import 'model.dart';

class DeliveryNoteRemoteDS {
  final APIClient _client;
  static const _baseRoute = ApiRoutes.deliveryNote;

  DeliveryNoteRemoteDS(this._client);

  /// 1️⃣ Fetch list records (only fields needed for listing)
  Future<Either<Failure, List<DeliveryNoteModel>>> getAll() async {
    try {
      final res = await _client.client.get(
        _baseRoute,
        queryParameters: {
          'fields':
              '["name", "customer_name", "status", "grand_total", "per_installed"]',
          'order_by': 'modified desc',
        },
      );

      final data = res.data;
      if (data == null || data['data'] == null) {
        throw handleException('Invalid response structure');
      }

      final list =
          (data['data'] as List)
              .map((e) => DeliveryNoteModel.fromJson(e as Map<String, dynamic>))
              .toList();

      return Right(list);
    } catch (e) {
      return Left(handleException(e));
    }
  }

  /// 2️⃣ Fetch a full record by ID
  Future<Either<Failure, DeliveryNoteModel>> getById(String id) async {
    try {
      final res = await _client.client.get('$_baseRoute/$id');
      final data = res.data?['data'];
      if (data == null) throw handleException('No data found');

      final model = DeliveryNoteModel.fromJson(data);
      return Right(model);
    } catch (e) {
      return Left(handleException(e));
    }
  }
}
