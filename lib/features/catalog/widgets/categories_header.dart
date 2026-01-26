import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/core.dart';

class CategoriesHeader extends StatelessWidget {
  const CategoriesHeader({
    super.key,
    required this.controller,
    required this.onBack,
  });

  final TextEditingController controller;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onBack,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: colors.stroke),
              ),
              child: const Icon(Icons.arrow_back, size: 20),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: _SearchBar(controller: controller)),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.stroke),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: colors.muted),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Search here...',
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () {},
            icon: const Icon(Icons.mic_none),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () {},
            icon: const Icon(Icons.camera_alt_outlined),
          ),
        ],
      ),
    );
  }
}
