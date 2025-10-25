import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:flutter/foundation.dart';
import '/core/errors/failures.dart';

import 'domain/sales_invoice.dart';
import 'domain/usecases.dart';

import 'package:dartz/dartz.dart';

class SalesInvoiceProvider with ChangeNotifier {
  final GetAllSalesInvoices getAllSalesInvoices;
  final GetSalesInvoiceById getById;
  final MarkSalesInvoiceAsPaid markPaid;

  SalesInvoiceProvider({
    required this.getAllSalesInvoices,
    required this.getById,
    required this.markPaid,
  });

  List<SalesInvoice> _invoices = [];
  List<SalesInvoice> get invoices => _invoices;

  SalesInvoice? _selectedinvoice;
  SalesInvoice? get selectedinvoice => _selectedinvoice;

  bool _listLoading = false;
  bool _detailLoading = false;

  bool get listLoading => _listLoading;
  bool get detailLoading => _detailLoading;
  bool get hasError => _failure != null;

  Failure? _failure;
  Failure? get failure => _failure;

  /// Fetch all sales invoices
  Future<void> fetchAll() async {
    _setListLoading(true);

    final result = await getAllSalesInvoices();
    result.fold(
      (f) {
        _failure = f;
        _invoices = [];
      },
      (list) {
        _failure = null;
        _invoices = list;
      },
    );

    _setListLoading(false);
  }

  /// Fetch single invoice by ID
  Future<void> fetchById(String id) async {
    _setDetailLoading(true);
    _failure = null;

    final result = await getById(id);
    result.fold((f) => _failure = f, (invoice) => _selectedinvoice = invoice);

    _setDetailLoading(false);
  }

  /// Mark sales invoice as paid
  Future<Either<Failure, Unit>> markInvoiceAsPaid({
    required String invoiceName,
    required String customerName,
    required String customer,
    required double amount,
    required String referenceNo,
    required String referenceDate,
  }) async {
    _setDetailLoading(true);
    _failure = null;

    appLogger.i("🔁 markInvoiceAsPaid called for invoice $invoiceName");

    final result = await markPaid(
      invoiceName: invoiceName,
      customerName: customerName,
      customer: customer,
      amount: amount,
      referenceNo: referenceNo,
      referenceDate: referenceDate,
    );

    appLogger.i("✅ Result from markPaid: $result");

    if (result.isRight() && _selectedinvoice != null) {
      await fetchById(_selectedinvoice!.id);
    }

    _setDetailLoading(false);
    return result;
  }

  void reset() {
    _invoices = [];
    _selectedinvoice = null;
    _failure = null;
    _listLoading = false;
    _detailLoading = false;
    notifyListeners();
  }

  void _setListLoading(bool value) {
    _listLoading = value;
    notifyListeners();
  }

  void _setDetailLoading(bool value) {
    _detailLoading = value;
    notifyListeners();
  }
}
