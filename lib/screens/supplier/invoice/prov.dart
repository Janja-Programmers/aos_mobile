import 'dart:convert';
import 'package:flutter/material.dart';

import '../../../core/utils/logger.dart';
import '/core/constants/const.dart';
import '/core/errors/exception.dart';
import '/core/errors/failures.dart';
import '/core/utils/api_client.dart';
import '/features/order/domain/sales_order.dart';

class SalesInvoiceProvider extends ChangeNotifier {
  final APIClient client;

  SalesInvoiceProvider(this.client);

  // 🔄 Loading states
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isDetailLoading = false;
  bool get isDetailLoading => _isDetailLoading;

  // ⚠️ Error
  Failure? _failure;
  Failure? get failure => _failure;

  // 📋 Data
  List<SalesOrder> _invoices = [];
  List<SalesOrder> get invoices => _invoices;

  SalesOrder? _selectedInvoice;
  SalesOrder? get selectedInvoice => _selectedInvoice;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setDetailLoading(bool value) {
    _isDetailLoading = value;
    notifyListeners();
  }

  /// ✅ Fetch all invoices
  Future<void> fetchInvoices({String? owner}) async {
    appLogger.i("🔄 Fetching invoices... owner=$owner");
    _setLoading(true);

    try {
      final queryParams = <String, dynamic>{
        'fields': jsonEncode([
          "name",
          "status",
          "customer_name",
          "grand_total",
          "outstanding_amount",
          "posting_date",
        ]),
        'order_by': 'modified desc',
        'limit': 100,
        if (owner != null) 'owner': owner,
      };

      appLogger.i("➡️ Query params: $queryParams");

      final res = await client.client.get(
        ApiRoutes.salesInvoice,
        queryParameters: queryParams,
      );

      final List rawData = res.data['data'] ?? [];
      appLogger.i("✅ Invoices fetched: ${rawData.length}");

      _invoices =
          rawData.map<SalesOrder>((e) {
            final map = Map<String, dynamic>.from(e);
            return SalesOrder(
              id: map["name"] ?? "",
              status: map["status"] ?? "",
              customerName: map["customer_name"] ?? "",
              grandTotal: (map["grand_total"] as num?)?.toDouble() ?? 0.0,
              deliveryDate: DateTime.now(),
              percentDelivered: 0.00,
              percentBilled: 0.00,
              items: [],
              shippingAddress: '',
            );
          }).toList();

      _failure = null;
    } catch (e) {
      _failure = handleException(e);
      _invoices = [];
      appLogger.e("❌ Failed to fetch invoices: $e");
    }

    _setLoading(false);
    appLogger.i("🏁 Finished fetching invoices. _invoices=${_invoices.length}");
  }

  /// ✅ Fetch one invoice by ID
  Future<void> fetchById(String id) async {
    appLogger.i("🔄 Fetching invoice by ID: $id");
    _setDetailLoading(true);
    _failure = null;

    try {
      final res = await client.client.get('${ApiRoutes.salesInvoice}/$id');
      final data = res.data['data'];

      appLogger.i("➡️ Raw response data: $data");

      if (data == null || data.isEmpty) {
        throw Exception("No invoice found with ID: $id");
      }

      final map = Map<String, dynamic>.from(data);
      _selectedInvoice = SalesOrder(
        id: map["name"] ?? "",
        status: map["status"] ?? "",
        customerName: map["customer_name"] ?? "",
        grandTotal: (map["grand_total"] as num?)?.toDouble() ?? 0.0,
        items: map["items"] ?? [],
        deliveryDate: DateTime.now(),
        percentDelivered: 0.00,
        percentBilled: 0.00,
        shippingAddress: '',
      );

      appLogger.i("✅ Invoice loaded: ${_selectedInvoice?.id}");
    } catch (e) {
      _failure = handleException(e);
      _selectedInvoice = null;
      appLogger.e("❌ Failed to fetch invoice by ID=$id: $e");
    }

    _setDetailLoading(false);
    appLogger.i("🏁 Finished fetching invoice by ID=$id");
  }
}
