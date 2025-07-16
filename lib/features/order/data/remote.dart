import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../core/utils/logger.dart';
import '/core/constants/const.dart';
import '/core/errors/exception.dart';
import '/core/errors/failures.dart';
import '/core/utils/api_client.dart';

import 'model.dart';

class SalesOrderRemoteDS {
  final APIClient client;
  static const _endpoint = SALES_ORDER_ENDPOINT;

  SalesOrderRemoteDS(this.client);

  // ✅ Fetch all orders
  Future<Either<Failure, List<SalesOrderModel>>> getAll({String? owner}) async {
    try {
      final queryParams = <String, dynamic>{
        'fields': jsonEncode([
          'name',
          'status',
          'customer_name',
          'grand_total',
          'per_delivered',
          'per_billed',
          'transaction_date',
          'items',
        ]),
        'order_by': 'modified desc',
        'limit': 100,
      };

      final res = await client.client.get(
        _endpoint,
        queryParameters: queryParams,
      );

      final List data = res.data['data'];
      final models = data.map((e) => SalesOrderModel.fromJson(e)).toList();
      return Right(models);
    } catch (e) {
      return Left(handleException(e));
    }
  }

  // ✅ Fetch one by ID
  Future<Either<Failure, SalesOrderModel>> getById(String id) async {
    try {
      final queryParams = {
        'filters': jsonEncode([
          ['name', '=', id],
        ]),
        'fields': jsonEncode([
          'name',
          'customer_name',
          'status',
          'grand_total',
          'per_delivered',
          'per_billed',
          'transaction_date',
        ]),
        'limit': 1,
        'expand': 1,
      };

      final res = await client.client.get(
        _endpoint,
        queryParameters: queryParams,
      );

      appLogger.i('Fetched single order with ID: $res');

      final data = res.data['data'];
      if (data == null || data.isEmpty) {
        throw Exception("No order found with ID: $id");
      }

      final model = SalesOrderModel.fromJson(data.first);
      return Right(model);
    } catch (e) {
      return Left(handleException(e));
    }
  }

  // ✅ Mark as delivered (PUT or custom endpoint)
  Future<Either<Failure, Unit>> markAsDelivered(String id) async {
    try {
      // Step 1: Create the delivery note from Sales Order
      final response = await client.client.post(
        '/api/method/erpnext.selling.doctype.sales_order.sales_order.make_delivery_note',
        data: {"source_name": id},
      );

      final draftDN = response.data['message'];
      appLogger.i('💡 Draft Delivery Note: $draftDN');

      // Step 2: Save the draft delivery note
      final saveResponse = await client.client.post(
        '/api/resource/Delivery Note',
        data: draftDN,
      );

      final dnName = saveResponse.data['data']['name'];
      appLogger.i('💾 Delivery Note saved: $dnName');

      // Step 3: Submit the delivery note (docstatus = 1)
      await client.client.put(
        '/api/resource/Delivery Note/$dnName',
        data: {"docstatus": 1},
      );

      appLogger.i('✅ Delivery Note submitted: $dnName');
      return const Right(unit);
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 403) {
        appLogger.e('Permission denied when marking order as delivered.');
        return Left(
          ServerFailure(
            'You do not have permission to mark this order as delivered.',
          ),
        );
      }

      appLogger.e('Unexpected error: $e');
      return Left(handleException(e));
    }
  }

  // ✅ Mark as billed
  Future<Either<Failure, Unit>> markAsBilled(String id) async {
    try {
      // Step 1: Create Sales Invoice from Sales Order
      final response = await client.client.post(
        '/api/method/erpnext.selling.doctype.sales_invoice.sales_invoice.make_sales_invoice',
        data: {"source_name": id},
      );

      appLogger.i('Created Sales Invoice from Sales Order: $response');

      final invoice = response.data['message'];
      final invoiceName = invoice['name'];

      appLogger.i('Sales Invoice created: $invoiceName');

      // Step 2: Submit the Sales Invoice (docstatus = 1)
      await client.client.put(
        '/api/resource/Sales Invoice/$invoiceName',
        data: {"docstatus": 1},
      );

      appLogger.i('Sales Invoice submitted successfully: $invoiceName');

      return const Right(unit);
    } catch (e) {
      appLogger.e('Error marking order as billed: $e');
      return Left(handleException(e));
    }
  }
}

class SalesOrderPayloadRemoteDS {
  final APIClient client;

  SalesOrderPayloadRemoteDS(this.client);

  Future<Either<Failure, Unit>> placeOrder(OrderPayloadModel order) async {
    try {
      await client.client.post(PLACE_ORDER_ENDPOINT, data: order.toJson());

      return const Right(unit);
    } catch (e) {
      return Left(handleException('Failed to place order: $e'));
    }
  }
}
