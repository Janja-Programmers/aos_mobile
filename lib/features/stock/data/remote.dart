import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '/core/constants/const.dart';
import '/core/errors/failures.dart';
import '/core/errors/exception.dart';
import '/core/utils/api_client.dart';

import '../domain/entity/stock.dart';

import 'models/stock.dart';

class StockEntryRemoteDS {
  final APIClient _client;

  StockEntryRemoteDS(this._client);

  Future<Either<Failure, List<StockEntry>>> getAll() async {
    try {
      final res = await _client.client.get(
        STOCK_ENTRY_ENDPOINT,
        queryParameters: {
          'fields': '["name", "owner", "docstatus", "modified", "vendor"]',
          'limit_page_length': 100,
          'order_by': 'creation desc',
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
    } catch (e, stack) {
      debugPrint('❌ StockEntryRemoteDS.getAll failed: $e\n$stack');
      return Left(handleException(e));
    }
  }

  Future<Either<Failure, StockEntryModel>> getById(String name) async {
    try {
      final res = await _client.client.get('$STOCK_ENTRY_ENDPOINT/$name');
      final model = StockEntryModel.fromJson(res.data['data']);
      return Right(model);
    } catch (e) {
      return Left(handleException(e));
    }
  }

  Future<Either<Failure, void>> add(StockEntryModel entry) async {
    try {
      await _client.client.post(STOCK_ENTRY_ENDPOINT, data: entry.toJson());
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

      await _client.client.put(
        '$STOCK_ENTRY_ENDPOINT/$id',
        data: entry.toJson(),
      );
      return const Right(null);
    } catch (e) {
      return Left(handleException(e));
    }
  }
}
