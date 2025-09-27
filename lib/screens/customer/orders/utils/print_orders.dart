import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '/features/order/domain/sales_order.dart'; // 👈 now using domain model
import '/core/utils/formatters.dart';
import '/screens/auth/auth_provider.dart';

Future<void> printSalesOrder(
  BuildContext context,
  SalesOrder order, // 👈 changed from SalesOrderModel
) async {
  final username = context.read<AuthProvider>().user?.username ?? 'Unknown';
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // 🟢 Header
            pw.Text(
              'Sales Order',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Order ID: ${order.id}',
              style: const pw.TextStyle(fontSize: 12),
            ),
            pw.Text(
              'Customer: ${order.customerName}',
              style: const pw.TextStyle(fontSize: 12),
            ),
            if (order.contactEmail != null)
              pw.Text(
                'Email: ${order.contactEmail}',
                style: const pw.TextStyle(fontSize: 12),
              ),
            if (order.contactPhone != null)
              pw.Text(
                'Phone: ${order.contactPhone}',
                style: const pw.TextStyle(fontSize: 12),
              ),

            pw.Text(
              'Shipping Address: ${order.shippingAddress}',
              style: const pw.TextStyle(fontSize: 12),
            ),
            pw.Divider(),

            // 🟢 Items Table
            pw.Table.fromTextArray(
              headers: ['#', 'Item Code', 'Item Name', 'Qty', 'Rate', 'Amount'],
              data: List.generate(order.items.length, (index) {
                final item = order.items[index];
                return [
                  '${index + 1}',
                  item.itemCode,
                  item.itemName,
                  '${item.qty}',
                  'Sh ${item.rate.toStringAsFixed(2)}',
                  'Sh ${item.amount.toStringAsFixed(2)}',
                ];
              }),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey800,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              cellStyle: const pw.TextStyle(fontSize: 10),
              cellAlignment: pw.Alignment.centerLeft,
              cellPadding: const pw.EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 3,
              ),
            ),

            pw.SizedBox(height: 16),

            // 🟢 Totals
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text(
                  'Grand Total: Sh ${order.grandTotal.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 16),

            // 🟢 Footer
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Status: ${order.status}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.Text(
                  'Printed by: $username',
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.Text(
                  'At: ${formatCompactDateTime(DateTime.now().toLocal())}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        );
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}
