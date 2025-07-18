import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '/features/order/domain/sales_order.dart';

Future<void> printSalesOrder(SalesOrder order) async {
  final pdf = pw.Document();

  final now = DateTime.now().toLocal().toString().split(' ')[0];

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return pw.Padding(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Text(
                'Sales Order',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(order.id, style: const pw.TextStyle(fontSize: 14)),

              pw.SizedBox(height: 16),

              // Order info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [pw.Text('Customer Name: ${order.customerName}')],
                  ),
                  pw.Text('Date: $now'),
                ],
              ),

              pw.SizedBox(height: 24),

              // Items table header
              pw.Table.fromTextArray(
                headers: [
                  'Sr',
                  'Item Code',
                  'Description',
                  'Qty',
                  'UOM',
                  'Rate',
                  'Amount',
                ],
                data:
                    order.items.asMap().entries.map((entry) {
                      final i = entry.key + 1;
                      final item = entry.value;
                      return [
                        '$i',
                        item.itemCode,
                        item.itemName,
                        '${item.qty}',
                        'KES ${item.rate.toStringAsFixed(2)}',
                        'KES ${item.amount.toStringAsFixed(2)}',
                      ];
                    }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.centerLeft,
                cellStyle: const pw.TextStyle(fontSize: 10),
                columnWidths: {
                  0: const pw.FixedColumnWidth(20),
                  1: const pw.FlexColumnWidth(),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FixedColumnWidth(30),
                  4: const pw.FixedColumnWidth(30),
                  5: const pw.FixedColumnWidth(50),
                  6: const pw.FixedColumnWidth(60),
                },
              ),

              pw.SizedBox(height: 24),

              // Totals
              pw.Text(
                'Total Quantity: ${order.items.fold<double>(0, (sum, item) => sum + item.qty)}',
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Grand Total: KES ${order.grandTotal.toStringAsFixed(2)}',
              ),

              pw.SizedBox(height: 16),

              // Optional address & extras
              ...[
                pw.Text('Address:'),
                pw.Text(order.shippingAddress),
                pw.SizedBox(height: 4),
              ],
              if (order.contactPhone != null)
                pw.Text('Phone: ${order.contactPhone}'),
              pw.SizedBox(height: 4),
              pw.Text(
                '% Picked: ${order.percentDelivered.toStringAsFixed(1)}%',
              ),
              pw.Text(
                'Amount Eligible for Commission: KES ${order.percentBilled.toStringAsFixed(2)}',
              ),
            ],
          ),
        );
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}
