import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/pickers/select_option_sheet.dart';
import 'package:africaonlinestores/features/ads/domain/ad_attribute.dart';
import 'package:africaonlinestores/features/ads/domain/ad_schema.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ad_draft_controller.dart';
import 'package:africaonlinestores/shared/components/app_date_picker.dart';
import 'package:africaonlinestores/shared/components/picker_field.dart';
import 'package:africaonlinestores/shared/enums/ads.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DetailsStep extends ConsumerWidget {
  const DetailsStep({super.key, required this.schema});

  final AdCategorySchema schema;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draftAsync = ref.watch(adDraftControllerProvider);

    final draft =
        draftAsync.value ?? ref.read(adDraftControllerProvider.notifier).draft;

    final ctrl = ref.read(adDraftControllerProvider.notifier);
    final categoryName = draft.categoryLabel;

    if (schema.attributes.isEmpty) {
      return Center(
        child: Text(
          'No additional details for this category.',
          style: context.p,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
      itemCount: schema.attributes.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add item specifics', style: context.pStrong),
              const SizedBox(height: 10),
              Text(
                categoryName == null
                    ? 'Provide details about your category'
                    : 'Provide details about your $categoryName',
                style: context.pMuted,
              ),
              const SizedBox(height: 12),
            ],
          );
        }

        if (index == 1) {
          return const SizedBox(height: 4);
        }

        final attr = schema.attributes[index - 2];
        final value = draft.attributes[attr.key];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _AttributeField(
            attribute: attr,
            value: value,
            onChanged: (Object? nextValue) {
              ctrl.setAttribute(attr.key, nextValue);
            },
          ),
        );
      },
    );
  }
}

class _AttributeField extends ConsumerWidget {
  const _AttributeField({
    required this.attribute,
    required this.value,
    required this.onChanged,
  });

  final AdAttribute attribute;
  final Object? value;
  final ValueChanged<Object?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (attribute.type) {
      case AdAttributeType.select:
        return PickerField(
          label: attribute.label,
          required: attribute.required,
          value: value?.toString(),
          helperText: _cleanText(attribute.helpText),
          placeholder: 'Select ${attribute.label.toLowerCase()}',
          onTap: () async {
            final picked = await showModalBottomSheet<String>(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) => SelectOptionSheet(
                title: attribute.label,
                options: attribute.options,
                selected: value?.toString(),
                helperText: _cleanText(attribute.helpText),
              ),
            );

            if (picked != null) {
              onChanged(picked);
            }
          },
        );

      case AdAttributeType.multiselect:
        final selected = _selectedValues(value);

        return PickerField(
          label: attribute.label,
          required: attribute.required,
          value: selected.isEmpty ? null : selected.join(', '),
          helperText: _cleanText(attribute.helpText),
          placeholder: 'Select ${attribute.label.toLowerCase()}',
          onTap: () async {
            final picked = await showModalBottomSheet<List<String>>(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) => SelectOptionSheet(
                title: attribute.label,
                options: attribute.options,
                selected: selected,
                multi: true,
                helperText: _cleanText(attribute.helpText),
              ),
            );

            if (picked != null) {
              onChanged(picked);
            }
          },
        );

      case AdAttributeType.boolean:
        final boolVal = value == true || value == 1;

        return SwitchListTile.adaptive(
          value: boolVal,
          title: Text(
            attribute.required ? '${attribute.label} *' : attribute.label,
            style: context.p,
          ),
          subtitle: _cleanText(attribute.helpText) == null
              ? null
              : Text(_cleanText(attribute.helpText)!, style: context.pMuted),
          contentPadding: EdgeInsets.zero,
          onChanged: onChanged,
        );

      case AdAttributeType.number:
      case AdAttributeType.year:
        return TextFormField(
          key: ValueKey(attribute.key),
          initialValue: value?.toString() ?? '',
          keyboardType: TextInputType.number,
          style: context.p,
          decoration: InputDecoration(
            labelText: attribute.required
                ? '${attribute.label} *'
                : attribute.label,
            labelStyle: context.p,
            helperText: _cleanText(attribute.helpText),
            helperStyle: context.pMuted,
            hintStyle: context.pMuted,
          ),
          onChanged: (String text) {
            final trimmed = text.trim();

            if (trimmed.isEmpty) {
              onChanged(null);
              return;
            }

            if (attribute.type == AdAttributeType.year) {
              onChanged(int.tryParse(trimmed));
              return;
            }

            onChanged(double.tryParse(trimmed));
          },
        );

      case AdAttributeType.date:
        final str = value?.toString();
        final parsed = str != null ? DateTime.tryParse(str) : null;

        return PickerField(
          label: attribute.label,
          required: attribute.required,
          value: parsed != null
              ? '${parsed.day}/${parsed.month}/${parsed.year}'
              : null,
          helperText: _cleanText(attribute.helpText),
          placeholder: 'Select ${attribute.label.toLowerCase()}',
          onTap: () async {
            final now = DateTime.now();

            final picked = await showAppDatePicker(
              context: context,
              initialDate: parsed ?? now,
              firstDate: DateTime(now.year - 20),
              lastDate: DateTime(now.year + 20),
            );

            if (picked != null) {
              onChanged(picked.toIso8601String().split('T').first);
            }
          },
        );

      case AdAttributeType.text:
      case AdAttributeType.unknown:
        return TextFormField(
          key: ValueKey(attribute.key),
          initialValue: value?.toString() ?? '',
          style: context.p,
          decoration: InputDecoration(
            labelText: attribute.required
                ? '${attribute.label} *'
                : attribute.label,
            labelStyle: context.p,
            helperText: _cleanText(attribute.helpText),
            helperStyle: context.pMuted,
            hintStyle: context.pMuted,
          ),
          onChanged: onChanged,
        );
    }
  }

  static String? _cleanText(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }

  static List<String> _selectedValues(Object? value) {
    if (value == null) {
      return <String>[];
    }

    if (value is Iterable<Object?>) {
      return value
          .map((Object? item) => item?.toString().trim() ?? '')
          .where((String item) => item.isNotEmpty)
          .toList();
    }

    final text = value.toString().trim();
    if (text.isEmpty) {
      return <String>[];
    }

    return text
        .split(',')
        .map((String item) => item.trim())
        .where((String item) => item.isNotEmpty)
        .toList();
  }
}
