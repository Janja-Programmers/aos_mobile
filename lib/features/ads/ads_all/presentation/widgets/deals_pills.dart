import 'package:flutter/material.dart';
import 'package:africaonlinestores/shared/enums/deal_type.dart';

class DealsPills extends StatelessWidget {
  const DealsPills({super.key, required this.selected, required this.onSelect});

  final DealType selected;
  final ValueChanged<DealType> onSelect;

  static const _types = DealType.values;

  String _label(DealType type) {
    switch (type) {
      case DealType.all:
        return 'All';
      case DealType.deals:
        return 'Deals';
      case DealType.flashSale:
        return 'Flash Sale';
      case DealType.offers:
        return 'Offers';
      case DealType.newProducts:
        return 'New';
    }
  }

  IconData? _icon(DealType type) {
    switch (type) {
      case DealType.deals:
        return Icons.local_offer;
      case DealType.flashSale:
        return Icons.flash_on;
      case DealType.offers:
        return Icons.percent;
      case DealType.newProducts:
        return Icons.new_releases;
      case DealType.all:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _types.length,
        itemBuilder: (context, i) {
          final type = _types[i];
          final selectedChip = type == selected;

          final icon = _icon(type);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ChoiceChip(
              selected: selectedChip,
              onSelected: (_) => onSelect(type),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 16),
                    const SizedBox(width: 4),
                  ],
                  Text(_label(type)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
