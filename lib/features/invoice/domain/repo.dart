import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';

import 'sales_invoice.dart';

abstract class SalesInvoiceRepo {
  Future<Either<Failure, List<SalesInvoice>>> getAll();

  // NEW: Get order by ID
  Future<Either<Failure, SalesInvoice>> getById(String id);

  // NEW: Mark as Paid
  Future<Either<Failure, Unit>> markAsPaid({
    required String invoiceName,
    required String customerName,
    required String customer,
    required double amount,
    required String referenceNo,
    required String referenceDate,
  });
}
