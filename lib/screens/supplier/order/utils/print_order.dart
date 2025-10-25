import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '/core/utils/formatters.dart';
import '/features/order/domain/sales_order.dart';

Future<void> printSalesOrder({
  required String username,
  required SalesOrder order,
}) async {
  final pdf = pw.Document();

  final now = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final logo = await imageFromAssetBundle('assets/logo.png');

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 28),
      build:
          (context) => [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header: title + logo
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Sales Order',
                          style: pw.TextStyle(
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 6),
                        pw.Text(
                          order.id,
                          style: pw.TextStyle(
                            fontSize: 14,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Date: ${DateFormat('yyyy-MM-dd').format(order.deliveryDate)}',
                          style: pw.TextStyle(
                            fontSize: 11,
                            color: PdfColors.grey600,
                          ),
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

                pw.SizedBox(height: 20),

                // Customer Details
                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Customer: ${order.customerName}',
                        style: pw.TextStyle(fontSize: 11),
                      ),
                      if (order.contactEmail != null)
                        pw.Text(
                          'Email: ${order.contactEmail}',
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey700,
                          ),
                        ),
                      if (order.contactPhone != null)
                        pw.Text(
                          'Phone: ${order.contactPhone}',
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey700,
                          ),
                        ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 20),

                // Items Table
                pw.TableHelper.fromTextArray(
                  border: const pw.TableBorder(
                    horizontalInside: pw.BorderSide(
                      width: 0.3,
                      color: PdfColors.grey400,
                    ),
                    verticalInside: pw.BorderSide(
                      width: 0.3,
                      color: PdfColors.grey400,
                    ),
                    top: pw.BorderSide(width: 0.5, color: PdfColors.grey500),
                    bottom: pw.BorderSide(width: 0.5, color: PdfColors.grey500),
                  ),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.grey300,
                  ),
                  headerHeight: 25,
                  cellHeight: 22,
                  cellAlignments: {
                    0: pw.Alignment.centerRight,
                    1: pw.Alignment.centerLeft,
                    2: pw.Alignment.centerRight,
                    3: pw.Alignment.centerRight,
                    4: pw.Alignment.centerRight,
                  },
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 11,
                  ),
                  cellStyle: const pw.TextStyle(fontSize: 10),
                  headers: ['#', 'Item', 'Qty', 'Rate', 'Amount'],
                  data: List.generate(order.items.length, (i) {
                    final item = order.items[i];
                    return [
                      '${i + 1}',
                      item.itemName,
                      humanizeNumber(item.qty),
                      formatCurrency(item.rate),
                      formatCurrency(item.amount),
                    ];
                  }),
                ),

                pw.SizedBox(height: 24),
                pw.Divider(),

                // Totals Section
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Row(
                        mainAxisSize: pw.MainAxisSize.min,
                        children: [
                          pw.Text(
                            'Grand Total: ',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          pw.Text(
                            formatCurrency(order.grandTotal),
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 24),
                pw.Divider(),

                // Footer Info
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Printed on: $now',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                      ),
                    ),
                    pw.Text(
                      'Generated by: $username',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                      ),
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
