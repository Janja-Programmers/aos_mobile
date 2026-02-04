import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/utils/app_snack.dart';
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

    final res = await ref.read(adsApiProvider).getAd(id: "AD-2026-00009");
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
        title: Text('AD DETAIL SCREEN', style: context.h4),
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
                    FilledButton(
                      onPressed: _load,
                      child: const Text('Retried'),
                    ),
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
                      Text(
                        _ad!.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _ad!.price.toString(),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                              for (final s in _ad!.specs)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Wrong ${s.values.first}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).hintColor,
                                              ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          'Wrong ${s.values.first}',
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
                        _ActionButton(
                          icon: Icons.home_outlined,
                          label: 'Home',
                          filled: false,
                          onTap: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.call,
                            label: 'Call',
                            filled: true,
                            onTap: () => ShowSnack(
                              context,
                              'Wire call action later',
                            ).info(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.chat_bubble_outline,
                            label: 'Message',
                            filled: false,
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
                    images[safeSelected],
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
                      images[i],
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
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      height: 48,
      child: filled
          ? FilledButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 18),
              label: Text(label),
            )
          : OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 18, color: colors.onSurface),
              label: Text(label),
            ),
    );
  }
}
