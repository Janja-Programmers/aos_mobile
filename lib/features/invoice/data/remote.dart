import 'dart:convert';

import 'package:dartz/dartz.dart';

import '/core/constants/const.dart';
import '/core/errors/exception.dart';
import '/core/errors/failures.dart';
import '/core/utils/api_client.dart';
import '/core/utils/logger.dart';

import '../domain/sales_invoice.dart';

import 'model.dart';

class SalesInvoiceRemoteDS {
  final APIClient client;
  static const salesInvoice = ApiRoutes.salesInvoice;
  static const payInvoice = ApiRoutes.payInvoice;

  SalesInvoiceRemoteDS(this.client);

  // ✅ Fetch all Invoices
  Future<Either<Failure, List<SalesInvoiceModel>>> getAll() async {
    try {
      final queryParams = <String, dynamic>{
        'fields': jsonEncode([
          'name',
          'status',
          'customer_name',
          'customer',
          'grand_total',
          'outstanding_amount',
          'due_date',
          'posting_date',
          'items',
        ]),
        'order_by': 'modified desc',
        'limit': 100,
      };

      final res = await client.client.get(
        ApiRoutes.salesInvoice,
        queryParameters: queryParams,
      );

      final List data = res.data['data'];
      final models = data.map((e) => SalesInvoiceModel.fromJson(e)).toList();
      return Right(models);
    } catch (e) {
      return Left(handleException(e));
    }
  }

  // ✅ Fetch one by ID
  Future<Either<Failure, SalesInvoice>> getById(String id) async {
    try {
      final res = await client.client.get('$salesInvoice/$id');
      final data = res.data['data'];

      if (data == null || data.isEmpty) {
        throw Exception("No Invoice found with ID: $id");
      }

      final model = SalesInvoiceModel.fromJson(data).toEntity();

      return Right(model);
    } catch (e) {
      return Left(handleException(e));
    }
  }

  // ✅ Mark as paid
  Future<Either<Failure, Unit>> markAsPaid({
    required String invoiceName,
    required String customerName,
    required String customer,
    required double amount,
    required String referenceNo,
    required String referenceDate,
  }) async {
    try {
      // 1️⃣ Insert Payment Entry
      final response = await client.client.post(
        payInvoice,
        data: {
          "doc": {
            "doctype": "Payment Entry",
            "payment_type": "Receive",
            "company": "Africa Online Stores",
            "party_type": "Customer",
            "party": customer,
            "posting_date": referenceDate,
            "mode_of_payment": "Cash",
            "paid_from": "Debtors - AOS",
            "paid_to": "Cash - AOS",
            "paid_amount": amount,
            "received_amount": amount,
            "reference_no": referenceNo,
            "reference_date": referenceDate,
            "references": [
              {
                "reference_doctype": "Sales Invoice",
                "reference_name": invoiceName,
                "allocated_amount": amount,
              },
            ],
          },
        },
      );

      final paymentEntry = response.data['message'];
      if (paymentEntry == null) {
        throw Exception('Payment Entry creation failed');
      }

      // 2️⃣ Submit Payment Entry (fixed)
      await client.client.post(
        '/api/method/frappe.client.submit',
        data: {"doc": paymentEntry},
      );

      return const Right(unit);
    } catch (e) {
      appLogger.e('⛔ Error marking invoice as paid: $e');
      return Left(handleException(e));
    }
  }
}
