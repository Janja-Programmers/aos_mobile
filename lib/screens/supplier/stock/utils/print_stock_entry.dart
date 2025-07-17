import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '/core/utils/formatters.dart';
import '/features/auth/presentation/auth_provider.dart';
import '/features/stock/domain/entity/stock.dart';

Future<void> printStockIntake(BuildContext context, StockEntry entry) async {
  final username = context.read<AuthProvider>().user!.username;
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
              '$username Stock Intake',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(entry.id, style: const pw.TextStyle(fontSize: 12)),
            pw.Divider(),

            // Table
            pw.Table.fromTextArray(
              headers: [
                'Sr',
                'Item Code',
                'Item Name',
                'Qty',
                'Valuation Rate',
              ],
              data: List.generate(entry.items.length, (index) {
                final item = entry.items[index];
                return [
                  '${index + 1}',
                  item.itemCode,
                  item.itemName,
                  item.qty.toStringAsFixed(0),
                  'Sh ${item.valuationRate.toStringAsFixed(2)}',
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

            pw.SizedBox(height: 32),

            // Footer Section
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Printed at: ${formatCompactDateTime(DateTime.now().toLocal())}',
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
