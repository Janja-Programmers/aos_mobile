import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import '/core/utils/formatters.dart';
import '/features/d_note/domain/entity/delivery_note.dart';

Future<void> printDeliveryNote(DeliveryNote note) async {
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
                /// Company header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Africa Online Stores',
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          'Official Delivery Note',
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    pw.SizedBox(
                      height: 50,
                      width: 50,
                      child: pw.Image(logo, fit: pw.BoxFit.contain),
                    ),
                  ],
                ),

                pw.SizedBox(height: 16),

                /// Delivery Note title & ID
                pw.Text(
                  'Delivery Note',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Note ID: ${note.id}',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 16),

                /// Delivery Date & Print Date
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    // Delivery date from the note (assumes a DateTime field `deliveryDate`)
                    pw.Text('Delivery Date: $now'),
                    // Print date (today)
                    pw.Text('Print Date: $now'),
                  ],
                ),

                pw.SizedBox(height: 12),

                /// Customer details block
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Customer: ${note.customerName}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text('Status: ${note.status}'),
                  ],
                ),

                pw.SizedBox(height: 24),

                /// Items table
                pw.Table(
                  border: pw.TableBorder.all(
                    width: 0.5,
                    color: PdfColors.grey600,
                  ),
                  columnWidths: {
                    0: const pw.FixedColumnWidth(20),
                    1: const pw.FlexColumnWidth(3),
                    2: const pw.FixedColumnWidth(40),
                    3: const pw.FixedColumnWidth(50),
                    4: const pw.FixedColumnWidth(60),
                  },
                  children: [
                    // Header row
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey300,
                      ),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            '#',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            'Item Code',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            'Qty',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            'Rate',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            'Amount',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Data rows
                    ...note.items.asMap().entries.map((entry) {
                      final i = entry.key;
                      final item = entry.value;
                      return pw.TableRow(
                        decoration:
                            i % 2 == 0
                                ? const pw.BoxDecoration(
                                  color: PdfColors.grey100,
                                )
                                : null,
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(
                              '${i + 1}',
                              style: const pw.TextStyle(fontSize: 10),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(
                              item.itemCode,
                              style: const pw.TextStyle(fontSize: 10),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(
                              '${item.qty}',
                              textAlign: pw.TextAlign.right,
                              style: const pw.TextStyle(fontSize: 10),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(
                              formatCurrency(item.rate),
                              textAlign: pw.TextAlign.right,
                              style: const pw.TextStyle(fontSize: 10),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(
                              formatCurrency(item.amount),
                              textAlign: pw.TextAlign.right,
                              style: const pw.TextStyle(fontSize: 10),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),

                pw.SizedBox(height: 24),

                /// Divider before totals
                pw.Divider(),

                /// Totals
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Total Qty:',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    pw.Text(
                      '${note.items.fold<double>(0, (sum, item) => sum + item.qty)}',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Grand Total:',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    pw.Text(
                      formatCurrency(note.grandTotal),
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),

                /// Footer note
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 32),
                  child: pw.Center(
                    child: pw.Text(
                      'This is an official delivery note from Africa Online Stores.',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontStyle: pw.FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
      footer:
          (context) => pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ),
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}
