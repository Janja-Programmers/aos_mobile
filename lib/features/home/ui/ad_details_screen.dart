import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';
import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/utils/app_snack.dart';
import 'package:africaonlinestores/features/ads/utils/file_url.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/providers/ads_api_provider.dart';
import 'package:africaonlinestores/ui/components/app_text_styles.dart';

class AdDetailsScreen extends ConsumerStatefulWidget {
  const AdDetailsScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<AdDetailsScreen> createState() => _AdDetailsScreenState();
}

class _AdDetailsScreenState extends ConsumerState<AdDetailsScreen> {
  bool _loading = true;
  String? _err;
  AOSAdDetails? _ad;
  int _selectedImage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _err = null;
    });

    final res = await ref.read(adsApiProvider).getAd(id: widget.id);
    if (!mounted) return;

    res.fold(
      (f) => setState(() {
        _loading = false;
        _err = f.message;
      }),
      (json) {
        final data = json['data'];
        final adJson = (data is Map) ? (data['item'] ?? data) : null;
        if (adJson is! Map) {
          setState(() {
            _loading = false;
            _err = 'Failed to load ad.';
          });
          return;
        }
        setState(() {
          _ad = AOSAdDetails.fromJson(Map<String, dynamic>.from(adJson));
          _loading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _err != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_err!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: _load, child: const Text('Retry')),
                  ],
                ),
              ),
            )
          : _ad == null
          ? const SizedBox.shrink()
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _ImageHeader(
                        images: _ad!.images,
                        selected: _selectedImage,
                        onSelect: (i) => setState(() => _selectedImage = i),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: colors.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              [
                                _ad!.locationName,
                                _ad!.country,
                              ].where((e) => e.trim().isNotEmpty).join(', '),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).hintColor,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(_ad!.title, style: context.h6),
                      const SizedBox(height: 10),
                      Text(
                        _ad!.priceDisplay.trim().isNotEmpty
                            ? _ad!.priceDisplay
                            : [
                                _ad!.currency,
                                (_ad!.price ?? 0).toString(),
                                if (_ad!.priceUnit.trim().isNotEmpty)
                                  _ad!.priceUnit,
                              ].where((e) => e.trim().isNotEmpty).join(' '),
                        style: context.pStrong.copyWith(
                          fontWeight: FontWeight.w900,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        title: 'Product Details',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Description',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _ad!.description.isEmpty
                                  ? 'No description.'
                                  : _ad!.description,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context).hintColor,
                                  ),
                            ),
                            const SizedBox(height: 14),
                            if (_ad!.specs.isNotEmpty) ...[
                              const Text(
                                'Specifications',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 10),
                              for (final s in _ad!.specs) _SpecRow(spec: s),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Row(
                      children: [
                        // ✅ HOME: icon-only
                        _ActionButton(
                          icon: Icons.home_outlined,
                          filled: false,
                          label: null,
                          onTap: () => context.push(AppRoutes.home),
                        ),
                        const SizedBox(width: 10),

                        // ✅ CALL: icon + label
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.call,
                            filled: true,
                            label: 'Call',
                            onTap: () => ShowSnack(
                              context,
                              'Wire call action later',
                            ).info(),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // ✅ MESSAGE: icon + label
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.chat_bubble_outline,
                            filled: false,
                            label: 'Message',
                            onTap: () => ShowSnack(
                              context,
                              'Wire chat action later',
                            ).info(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

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
      // ✅ Icon-only (Home)
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

    // ✅ Icon + label (Call / Message)
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
