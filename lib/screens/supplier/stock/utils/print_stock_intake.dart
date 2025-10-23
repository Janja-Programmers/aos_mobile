import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '/core/utils/formatters.dart';

import '/features/stock/domain/entity/stock.dart';

Future<void> printStockIntake({
  required String username,
  required StockEntry entry,
}) async {
  final pdf = pw.Document();

  final now = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final logo = await imageFromAssetBundle('assets/logo.png');

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(24),
      build:
          (context) => [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      '$username Stock Intake',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(
                      height: 50,
                      width: 50,
                      child: pw.Image(logo, fit: pw.BoxFit.contain),
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),
                pw.Text(
                  'Entry ID: ${entry.id}',
                  style: pw.TextStyle(fontSize: 12),
                ),
                pw.Text('Date: $now', style: pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 16),

                pw.Table.fromTextArray(
                  headers: ['#', 'Item Code', 'Item Name', 'Qty', 'Rate'],
                  data: List.generate(entry.items.length, (i) {
                    final item = entry.items[i];
                    return [
                      '${i + 1}',
                      item.itemCode,
                      item.itemName,
                      item.qty.toStringAsFixed(0),
                      formatCurrency(item.valuationRate),
                    ];
                  }),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.grey300,
                  ),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  cellStyle: const pw.TextStyle(fontSize: 10),
                ),

                pw.SizedBox(height: 24),
                pw.Divider(),

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Printed on: $now',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ],
    ),
  );

  await Printing.layoutPdf(onLayout: (format) async => pdf.save());
}
