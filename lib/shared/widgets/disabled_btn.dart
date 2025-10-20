import 'package:flutter/material.dart';

Widget buildDisabledButton({
  required String label,
  required IconData icon,
  required Color color,
  FontWeight fontWeight = FontWeight.w500,
}) {
  return ElevatedButton.icon(
    onPressed: null,
    icon: Icon(icon, color: color, size: 18),
    label: Text(label, style: TextStyle(color: color, fontWeight: fontWeight)),
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(120, 40),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      disabledBackgroundColor: Colors.grey.shade200,
      disabledForegroundColor: color,
      textStyle: const TextStyle(fontSize: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
  );
}
