import 'package:flutter/material.dart';

import '/shared/widgets/docstatus_chip.dart';

Widget buildSubTitle({required String title, int? docstatus}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      if (docstatus != null) ...[
        const SizedBox(width: 8),
        DocstatusChip(docstatus: docstatus),
      ],
    ],
  );
}
