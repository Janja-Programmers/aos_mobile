import 'package:africaonlinestores/features/localization/domain/locale_bundle.dart';

String? labelFor(List<LocaleOption> items, String? codeOrLabel) {
  final v = codeOrLabel?.trim();
  if (v == null || v.isEmpty) return null;

  final upper = v.toUpperCase();

  // Prefer code match (case-insensitive)
  for (final it in items) {
    if (it.code.trim().toUpperCase() == upper) return it.label;
  }

  // If not found, it might already be a label
  for (final it in items) {
    if (it.label.trim() == v) return it.label;
  }

  // Unknown
  return null;
}
