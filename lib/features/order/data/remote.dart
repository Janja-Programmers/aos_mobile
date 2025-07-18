import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '/core/constants/const.dart';
import '/core/errors/exception.dart';
import '/core/errors/failures.dart';
import '/core/utils/api_client.dart';
import '/core/utils/logger.dart';

import '../domain/sales_order.dart';

import 'model.dart';

class SalesOrderRemoteDS {
  final APIClient client;
  static const _endpoint = ApiRoutes.salesOrder;
  static const deliver = ApiRoutes.deliver;
  static const deliveryNote = ApiRoutes.deliveryNote;
  static const bill = ApiRoutes.bill;
  static const salesInvoice = ApiRoutes.salesInvoice;
  static const viewPastOrders = ApiRoutes.viewPastOrders;

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

  // ✅ Fetch orders for customer
  Future<Either<Failure, List<SalesOrderModel>>> getCustomerOrders() async {
    try {
      final res = await client.client.post(
        viewPastOrders,
        data: {"doctype": "Sales Order"},
      );

      final rawResultString = res.data['message']?['raw_result'];

      final data = jsonDecode(rawResultString ?? '[]');

      if (data is! List) {
        throw Exception('Expected a list but got: $data');
      }

      final models = data.map((e) => SalesOrderModel.fromJson(e)).toList();

      return Right(models);
    } catch (e) {
      return Left(handleException(e));
    }
  }

  // ✅ Fetch one by ID
  Future<Either<Failure, SalesOrder>> getById(String id) async {
    try {
      final res = await client.client.get('$_endpoint/$id');
      final data = res.data['data'];

      if (data == null || data.isEmpty) {
        throw Exception("No order found with ID: $id");
      }

      final model = SalesOrderModel.fromJson(data).toEntity();
      return Right(model);
    } catch (e) {
      return Left(handleException(e));
    }
  }

  // ✅ Mark as delivered (PUT or custom endpoint)
  Future<Either<Failure, Unit>> markAsDelivered(String id) async {
    const int docstatusSubmitted = 1;

    try {
      final response = await client.client.post(
        deliver,
        data: {"source_name": id},
      );
      final draftDN = response.data['message'];
      if (draftDN == null) throw Exception('Failed to create delivery note');

      final saveResponse = await client.client.post(
        deliveryNote,
        data: draftDN,
      );

      final dnName = saveResponse.data['data']['name'];
      if (dnName == null) throw Exception('Delivery Note save failed');

      await client.client.put(
        '$deliveryNote/$dnName',
        data: {"docstatus": docstatusSubmitted},
      );
      return const Right(unit);
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 403) {
        return Left(ServerFailure('Permission denied for delivery.'));
      }
      return Left(handleException(e));
    }
  }

  // ✅ Mark as billed
  Future<Either<Failure, Unit>> markAsBilled(String id) async {
    try {
      // Step 1: Create Sales Invoice draft from Sales Order
      final response = await client.client.post(
        bill,
        data: {"source_name": id},
      );

      final draftInvoice = response.data['message'];
      if (draftInvoice == null) {
        throw Exception('Failed to create Sales Invoice draft');
      }

      // Step 2: Save the Sales Invoice
      final saveResponse = await client.client.post(
        salesInvoice,
        data: draftInvoice,
      );

      final invoiceName = saveResponse.data['data']['name'];
      if (invoiceName == null) {
        throw Exception('Failed to save Sales Invoice');
      }

      // Step 3: Submit the invoice (docstatus = 1)
      await client.client.put(
        '$salesInvoice/$invoiceName',
        data: {"docstatus": 1},
      );

      return const Right(unit);
    } catch (e) {
      appLogger.e('⛔ Error marking order as billed: $e');
      return Left(handleException(e));
    }
  }
}

class SalesOrderPayloadRemoteDS {
  final APIClient client;
  static const placeOrderEndpoint = ApiRoutes.placeOrder;

  SalesOrderPayloadRemoteDS(this.client);

  Future<Either<Failure, Unit>> placeOrder(OrderPayloadModel order) async {
    try {
      await client.client.post(placeOrderEndpoint, data: order.toJson());

      return const Right(unit);
    } catch (e) {
      return Left(handleException('Failed to place order: $e'));
    }
  }
}

Map<String, dynamic> toCustomerOrderMap(SalesOrderModel model) {
  return {
    'id': model.id,
    'buyer': model.customerName,
    'date': model.deliveryDate,
    'status': model.status,
    'items':
        model.items
            .map(
              (i) => {
                'name': i.itemName,
                'qty': i.qty,
                'rate': i.rate,
                'amount': i.amount,
              },
            )
            .toList(),
    'total': model.grandTotal,
  };
}
