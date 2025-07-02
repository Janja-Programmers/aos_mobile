import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '/features/d_note/domain/entity/delivery_note.dart';

Future<void> printDeliveryNote(DeliveryNote note) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Delivery Note',
              style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 16),

            pw.Text('Customer: ${note.customerName}'),
            pw.Text('Status: ${note.status}'),
            pw.Text('Total: KES ${note.grandTotal.toStringAsFixed(2)}'),
            pw.Text(
              '% Installed: ${note.percentInstalled.toStringAsFixed(0)}%',
            ),
            pw.Text('ID: ${note.id}'),

            pw.SizedBox(height: 24),

            pw.Text(
              'Items:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),

            // ignore: deprecated_member_use
            pw.Table.fromTextArray(
              headers: ['Item', 'Qty', 'Rate', 'Amount'],
              data:
                  note.items.map((e) {
                    return [
                      '${e.itemName} (${e.itemCode})',
                      e.qty.toStringAsFixed(2),
                      e.rate.toStringAsFixed(2),
                      e.amount.toStringAsFixed(2),
                    ];
                  }).toList(),
              border: null,
              cellStyle: const pw.TextStyle(fontSize: 10),
              headerStyle: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              cellAlignment: pw.Alignment.centerLeft,
              cellPadding: const pw.EdgeInsets.symmetric(
                vertical: 4,
                horizontal: 6,
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
