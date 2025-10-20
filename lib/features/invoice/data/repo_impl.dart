import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';

import '../domain/repo.dart';
import '../domain/sales_invoice.dart';

import 'remote.dart';

class SalesInvoiceRepoImpl implements SalesInvoiceRepo {
  final SalesInvoiceRemoteDS remote;

  SalesInvoiceRepoImpl({required this.remote});

  @override
  Future<Either<Failure, List<SalesInvoice>>> getAll() async {
    final result = await remote.getAll();
    return result.map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Either<Failure, SalesInvoice>> getById(String id) async {
    return await remote.getById(id);
  }

  @override
  Future<Either<Failure, Unit>> markAsPaid({
    required String invoiceName,
    required String customerName,
    required double amount,
    required String referenceNo,
    required String referenceDate,
  }) {
    return remote.markAsPaid(
      invoiceName: invoiceName,
      customerName: customerName,
      amount: amount,
      referenceNo: referenceNo,
      referenceDate: referenceDate,
    );
  }
}
