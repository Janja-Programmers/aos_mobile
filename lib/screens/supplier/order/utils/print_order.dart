import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '/features/order/domain/sales_order.dart';

Future<void> printSalesOrder(SalesOrder order) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Sales Order', style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 16),
            pw.Text('Customer: ${order.customerName}'),
            pw.Text('Status: ${order.status}'),
            pw.Text(
              'Delivery Date: ${order.deliveryDate.toLocal().toString().split(' ').first}',
            ),
            pw.Text('Grand Total: KES ${order.grandTotal.toStringAsFixed(2)}'),
            pw.Text('% Delivered: ${order.percentDelivered}%'),
            pw.Text('% Billed: ${order.percentBilled}%'),
            pw.SizedBox(height: 24),
            pw.Text(
              'Items:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Divider(),
            ...order.items.map(
              (item) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('• ${item.itemName} (${item.itemCode})'),
                  pw.Text(
                    '  Qty: ${item.qty}  | Rate: ${item.rate}  | Amount: ${item.amount}',
                  ),
                  pw.SizedBox(height: 8),
                ],
              ),
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
