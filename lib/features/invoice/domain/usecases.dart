import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';

import 'repo.dart';
import 'sales_invoice.dart';

class GetAllSalesInvoices {
  final SalesInvoiceRepo repo;

  GetAllSalesInvoices(this.repo);

  Future<Either<Failure, List<SalesInvoice>>> call() => repo.getAll();
}

class GetSalesInvoiceById {
  final SalesInvoiceRepo repo;

  GetSalesInvoiceById(this.repo);

  Future<Either<Failure, SalesInvoice>> call(String id) {
    return repo.getById(id);
  }
}

class MarkSalesInvoiceAsPaid {
  final SalesInvoiceRepo repo;

  MarkSalesInvoiceAsPaid(this.repo, {required});

  Future<Either<Failure, Unit>> call({
    required String invoiceName,
    required String customerName,
    required String customer,
    required double amount,
    required String referenceNo,
    required String referenceDate,
  }) {
    return repo.markAsPaid(
      invoiceName: invoiceName,
      customerName: customerName,
      customer: customer,
      amount: amount,
      referenceNo: referenceNo,
      referenceDate: referenceDate,
    );
  }
}
