import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '/core/constants/const.dart';
import '/core/errors/failures.dart';
import '/core/errors/exception.dart';
import '/core/utils/api_client.dart';

import '../domain/entity/stock.dart';

import 'models/stock.dart';

class StockEntryRemoteDS {
  final APIClient _client;
  static const stockIntakeApi = ApiRoutes.stockIntake;

  StockEntryRemoteDS(this._client);

  Future<Either<Failure, List<StockEntry>>> getAll() async {
    try {
      final res = await _client.client.get(
        stockIntakeApi,
        queryParameters: {
          'fields': '["name", "docstatus", "modified"]',
          'order_by': 'modified desc',
        },
      );

      final data = res.data['data'];
      if (data is! List) throw Exception("Expected a list, got: $data");

      final entries =
          data
              .map((e) {
                try {
                  return StockEntryModel.fromJson(e).toEntity();
                } catch (e) {
                  handleException('Error parsing stock entry');
                  return null;
                }
              })
              .whereType<StockEntry>()
              .toList();

      return Right(entries);
    } catch (e) {
      return Left(handleException(e));
    }
  }

  Future<Either<Failure, StockEntryModel>> getById(String name) async {
    try {
      final res = await _client.client.get('$stockIntakeApi/$name');
      final model = StockEntryModel.fromJson(res.data['data']);
      return Right(model);
    } catch (e) {
      return Left(handleException(e));
    }
  }

  Future<Either<Failure, void>> add(StockEntryModel entry) async {
    try {
      await _client.client.post(stockIntakeApi, data: entry.toJson());
      return const Right(null);
    } catch (e) {
      return Left(handleException(e));
    }
  }

  Future<Either<Failure, void>> update(StockEntryModel entry) async {
    try {
      final id = entry.id;
      if (id.isEmpty) {
        return Left(handleException('Missing Stock Entry ID for update.'));
      }


      try {
      } on DioException catch (e) {
        return Left(handleException(e));
      }

      return const Right(null);
    } catch (e) {
      return Left(handleException(e));
    }
  }

  Future<Either<Failure, void>> deleteEntry(String id) async {
    try {
      await _client.client.delete('$stockIntakeApi/$id');
      return const Right(null);
    } catch (e) {
      return Left(handleException(e));
    }
  }
}
