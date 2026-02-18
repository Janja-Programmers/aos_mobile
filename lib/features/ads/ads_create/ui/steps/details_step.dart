import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/ads/domain/ad_schema.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ad_draft_controller.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/pickers/select_option_screen.dart';
import 'package:africaonlinestores/features/ads/ads_create/ui/widgets/picker_field.dart';

class DetailsStep extends ConsumerWidget {
  const DetailsStep({super.key, required this.schema});

  final AdCategorySchema schema;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(adDraftControllerProvider).maybeWhen(data: (v) => v, orElse: () => null);
    if (draft == null) return const SizedBox.shrink();
    final ctrl = ref.read(adDraftControllerProvider.notifier);

    if (schema.attributes.isEmpty) {
      return Center(
        child: Text(
          'No additional details for this category.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
      children: [
        Text('Item specifics', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        ...schema.attributes.map((a) {
          final value = draft.attributes[a.key];

          switch (a.type) {
            case AdAttributeType.select:
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PickerField(
                  label: a.label,
                  required: a.required,
                  value: value?.toString(),
                  onTap: () async {
                    final picked = await Navigator.of(context).push<String>(
                      MaterialPageRoute(
                        builder: (_) => SelectOptionScreen(
                          title: a.label,
                          options: a.options,
                          selected: value,
                        ),
                      ),
                    );
                    if (picked != null) ctrl.setAttribute(a.key, picked);
                  },
                ),
              );
            case AdAttributeType.multiselect:
              final selected = (value is List) ? value.map((e) => e.toString()).toList() : <String>[];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PickerField(
                  label: a.label,
                  required: a.required,
                  value: selected.isEmpty ? null : selected.join(', '),
                  onTap: () async {
                    final picked = await Navigator.of(context).push<List<String>>(
                      MaterialPageRoute(
                        builder: (_) => SelectOptionScreen(
                          title: a.label,
                          options: a.options,
                          selected: selected,
                          multi: true,
                        ),
                      ),
                    );
                    if (picked != null) ctrl.setAttribute(a.key, picked);
                  },
                ),
              );
            case AdAttributeType.boolean:
              final boolVal = value == true;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SwitchListTile.adaptive(
                  value: boolVal,
                  title: Text(a.required ? '${a.label} *' : a.label),
                  onChanged: (v) => ctrl.setAttribute(a.key, v),
                ),
              );
            case AdAttributeType.number:
            case AdAttributeType.year:
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextFormField(
                  initialValue: value?.toString() ?? '',
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: a.required ? '${a.label} *' : a.label),
                  onChanged: (v) {
                    final parsed = double.tryParse(v.trim());
                    ctrl.setAttribute(a.key, parsed);
                  },
                ),
              );
            case AdAttributeType.date:
              final str = value?.toString();
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PickerField(
                  label: a.label,
                  required: a.required,
                  value: str,
                  onTap: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      firstDate: DateTime(now.year - 20),
                      lastDate: DateTime(now.year + 20),
                      initialDate: now,
                    );
                    if (picked != null) {
                      ctrl.setAttribute(a.key, picked.toIso8601String().split('T').first);
                    }
                  },
                ),
              );
            case AdAttributeType.text:
            case AdAttributeType.unknown:
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextFormField(
                  initialValue: value?.toString() ?? '',
                  decoration: InputDecoration(labelText: a.required ? '${a.label} *' : a.label),
                  onChanged: (v) => ctrl.setAttribute(a.key, v),
                ),
              );
          }
        }),
      ],
    );
  }
}
