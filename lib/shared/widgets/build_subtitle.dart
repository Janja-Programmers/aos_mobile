import 'package:flutter/material.dart';

import '/shared/widgets/docstatus_chip.dart';
import '/shared/utils/doc_status.dart';

Widget buildSubTitle({required String title, DocStatus? docstatus}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      ...[const SizedBox(width: 8), DocstatusChip(docstatus: docstatus!)],
    ],
  );
}
