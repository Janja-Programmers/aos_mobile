import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';
import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/utils/app_snack.dart';
import 'package:africaonlinestores/features/ads/utils/file_url.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/providers/ads_api_provider.dart';
import 'package:africaonlinestores/ui/components/app_text_styles.dart';

part 'ad_details_screen_parts.dart';

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
