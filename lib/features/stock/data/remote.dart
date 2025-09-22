import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '/core/constants/const.dart';
import '/core/errors/failures.dart';
import '/core/errors/exception.dart';
import '/core/utils/api_client.dart';

import 'models/stock.dart';

class StockEntryRemoteDS {
  final APIClient _client;
  static const stockIntakeApi = ApiRoutes.stockIntake;

  StockEntryRemoteDS(this._client);
  Future<Either<Failure, List<StockEntryModel>>> getAll() async {
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

      final entries = data.map((e) => StockEntryModel.fromJson(e)).toList();

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

  Future<Either<Failure, StockEntryModel>> add(StockEntryModel entry) async {
    try {
      final res = await _client.client.post(
        stockIntakeApi,
        data: entry.toJson(),
      );
      final model = StockEntryModel.fromJson(res.data['data']);
      return Right(model);
    } catch (e) {
      return Left(handleException(e));
    }
  }

  Future<Either<Failure, StockEntryModel>> update(StockEntryModel entry) async {
    try {
      if (entry.id.isEmpty) {
        return Left(handleException('Missing Stock Entry ID for update.'));
      }

      final res = await _client.client.put(
        '$stockIntakeApi/${entry.id}',
        data: entry.toJson(),
      );

      final model = StockEntryModel.fromJson(res.data['data']);
      return Right(model);
    } on DioException catch (e) {
      return Left(handleException(e));
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
