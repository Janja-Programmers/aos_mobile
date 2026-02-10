part of 'ad_details_screen.dart';

class _ImageHeader extends StatelessWidget {
  const _ImageHeader({
    required this.images,
    required this.selected,
    required this.onSelect,
  });

  final List<String> images;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final safeSelected = images.isEmpty
        ? 0
        : selected.clamp(0, images.length - 1);

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.2,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Theme.of(context).dividerColor.withOpacity(0.08),
            ),
            clipBehavior: Clip.antiAlias,
            child: images.isEmpty
                ? const Center(child: Icon(Icons.image_outlined, size: 40))
                : Image.network(
                    buildFileUrl(images[safeSelected]) ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        const Center(child: Icon(Icons.broken_image_outlined)),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        if (images.length > 1)
          SizedBox(
            height: 62,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final active = i == safeSelected;
                return InkWell(
                  onTap: () => onSelect(i),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: active
                            ? colors.primary
                            : Theme.of(context).dividerColor.withOpacity(0.2),
                        width: active ? 2 : 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      buildFileUrl(images[i]) ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Center(
                        child: Icon(Icons.broken_image_outlined, size: 18),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _SpecRow extends StatelessWidget {
  const _SpecRow({required this.spec});

  final Map<String, String> spec;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    String key = (spec['label'] ?? spec['key'] ?? spec['name'] ?? '')
        .toString();
    String val = (spec['value'] ?? spec['val'] ?? '').toString();

    if (key.trim().isEmpty || val.trim().isEmpty) {
      if (spec.entries.isNotEmpty) {
        final e = spec.entries.first;
        key = key.trim().isEmpty ? e.key.toString() : key;
        val = val.trim().isEmpty ? e.value.toString() : val;
      }
    }

    key = key.trim();
    val = val.trim();

    if (key.isEmpty && val.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              key.isEmpty ? 'Specification' : key,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).hintColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              val,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.filled,
    required this.onTap,
    this.label,
  });

  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  /// If null/empty => icon-only button (used for Home).
  final String? label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final appColors = context.appColors;

    final isIconOnly = (label == null || label!.trim().isEmpty);

    // Color rules you requested:
    // - Outlined: primary
    // - Filled: appColors.border
    final iconColor = filled ? appColors.border : scheme.primary;
    final textColor = filled ? appColors.border : scheme.primary;

    if (isIconOnly) {
      return SizedBox(
        height: 48,
        width: 48,
        child: filled
            ? FilledButton(
                onPressed: onTap,
                style: FilledButton.styleFrom(padding: EdgeInsets.zero),
                child: Icon(icon, size: 20, color: iconColor),
              )
            : OutlinedButton(
                onPressed: onTap,
                style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
                child: Icon(icon, size: 20, color: iconColor),
              ),
      );
    }

    return SizedBox(
      height: 48,
      child: filled
          ? FilledButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 18, color: iconColor),
              label: Text(
                label!,
                style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
              ),
            )
          : OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 18, color: iconColor),
              label: Text(
                label!,
                style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
              ),
            ),
    );
  }
}
