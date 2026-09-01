import 'dart:async';

import 'package:africaonlinestores/core/config/app_config.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/maps/application/map_picker_controller.dart';
import 'package:africaonlinestores/features/maps/domain/aos_place.dart';
import 'package:africaonlinestores/features/maps/presentation/widgets/maplibre_platform_chrome.dart';
import 'package:africaonlinestores/features/sellers/location/application/seller_location_controller.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class SellerLocationScreen extends ConsumerStatefulWidget {
  const SellerLocationScreen({super.key});

  @override
  ConsumerState<SellerLocationScreen> createState() =>
      _SellerLocationScreenState();
}

class _SellerLocationScreenState extends ConsumerState<SellerLocationScreen> {
  static const LatLng _fallbackCenter = LatLng(-1.286389, 36.817223);

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  Timer? _debounce;
  MapLibreMapController? _mapController;
  bool _hydrated = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(sellerLocationControllerProvider.notifier).load();
      if (!mounted) return;
      final location = ref.read(sellerLocationControllerProvider).location;
      if (location != null) {
        ref.read(mapPickerControllerProvider.notifier).selectPlace(location);
        _hydrate(location);
      } else {
        setState(() => _hydrated = true);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _nameController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _hydrate(AOSPlace place) {
    if (_hydrated) return;
    _nameController.text = place.name;
    _instructionsController.text = place.instructions ?? '';
    setState(() => _hydrated = true);
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      unawaited(ref.read(mapPickerControllerProvider.notifier).search(value));
    });
  }

  Future<void> _selectPlace(AOSPlace place) async {
    ref.read(mapPickerControllerProvider.notifier).selectPlace(place);
    _searchController.text = place.displayAddress.isNotEmpty
        ? place.displayAddress
        : place.shortLabel;
    if (_nameController.text.trim().isEmpty) {
      _nameController.text = place.shortLabel;
    }
    await _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(place.latitude, place.longitude), 16),
    );
    if (mounted) setState(() {});
  }

  Future<void> _useCurrentLocation() async {
    await ref.read(mapPickerControllerProvider.notifier).useCurrentLocation();
    if (!mounted) return;
    final selected = ref.read(mapPickerControllerProvider).selected;
    if (selected != null) await _selectPlace(selected);
  }

  Future<void> _save() async {
    final selected = ref.read(mapPickerControllerProvider).selected;
    if (selected == null) {
      ShowSnack(context, 'Choose a valid location before saving.').info();
      return;
    }

    final ok = await ref
        .read(sellerLocationControllerProvider.notifier)
        .save(
          place: selected,
          locationName: _nameController.text,
          instructions: _instructionsController.text,
        );

    if (!mounted) return;
    if (ok) {
      ShowSnack(context, 'Storefront location updated.').success();
      context.pop(true);
      return;
    }

    ShowSnack(
      context,
      ref.read(sellerLocationControllerProvider).error ??
          'Failed to save location.',
    ).error();
  }

  Future<void> _remove() async {
    final ok = await ref
        .read(sellerLocationControllerProvider.notifier)
        .remove();
    if (!mounted) return;
    if (!ok) {
      ShowSnack(
        context,
        ref.read(sellerLocationControllerProvider).error ??
            'Failed to remove location.',
      ).error();
      return;
    }

    ref.read(mapPickerControllerProvider.notifier).clearSelection();
    _searchController.clear();
    _nameController.clear();
    _instructionsController.clear();
    setState(() {});
    ShowSnack(context, 'Storefront location removed.').success();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final locationState = ref.watch(sellerLocationControllerProvider);
    final pickerState = ref.watch(mapPickerControllerProvider);
    final selected = pickerState.selected ?? locationState.location;
    final target = selected == null
        ? _fallbackCenter
        : LatLng(selected.latitude, selected.longitude);
    final busy = locationState.saving || pickerState.resolving;

    ref.listen(mapPickerControllerProvider.select((state) => state.error), (
      previous,
      next,
    ) {
      if (next != null && next != previous && mounted) {
        ShowSnack(context, next).error();
      }
    });

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Text('Storefront Location', style: context.h5),
        centerTitle: false,
      ),
      body: SafeArea(
        child: locationState.loading && !_hydrated
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                children: [
                  Text(
                    'Choose the exact public location buyers should see.',
                    style: context.pMuted,
                  ),
                  const SizedBox(height: 18),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.elevated,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: colors.border),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              hintText:
                                  'Search town, road, landmark or building',
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: pickerState.loading
                                  ? const Padding(
                                      padding: EdgeInsets.all(12),
                                      child: SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          if (pickerState.results.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 220),
                              child: ListView.separated(
                                shrinkWrap: true,
                                itemCount: pickerState.results.length,
                                separatorBuilder: (_, _) =>
                                    Divider(height: 1, color: colors.border),
                                itemBuilder: (context, index) {
                                  final place = pickerState.results[index];
                                  return ListTile(
                                    dense: true,
                                    leading: Icon(
                                      Icons.location_on_outlined,
                                      color: colors.primary,
                                    ),
                                    title: Text(
                                      place.shortLabel,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(
                                      place.displayAddress,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    onTap: () => unawaited(_selectPlace(place)),
                                  );
                                },
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: OutlinedButton.icon(
                              onPressed: busy
                                  ? null
                                  : () => unawaited(_useCurrentLocation()),
                              icon: const Icon(Icons.my_location_rounded),
                              label: const Text('Use my current location'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: SizedBox(
                      height: 360,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: MapLibreMap(
                              key: ValueKey(
                                '${target.latitude}:${target.longitude}',
                              ),
                              styleString: AppConfig.mapStyleUrl,
                              initialCameraPosition: CameraPosition(
                                target: target,
                                zoom: selected == null ? 11 : 16,
                              ),
                              myLocationEnabled: true,
                              attributionButtonMargins:
                                  aosMapAttributionButtonMargins,
                              onMapCreated: (controller) {
                                _mapController = controller;
                              },
                              onMapClick: (_, coordinates) {
                                unawaited(
                                  ref
                                      .read(
                                        mapPickerControllerProvider.notifier,
                                      )
                                      .selectCoordinates(
                                        coordinates.latitude,
                                        coordinates.longitude,
                                      ),
                                );
                              },
                            ),
                          ),
                          const Center(
                            child: IgnorePointer(
                              child: Icon(
                                Icons.location_pin,
                                size: 52,
                                color: Colors.red,
                              ),
                            ),
                          ),
                          PositionedDirectional(
                            top: 12,
                            end: 12,
                            child: Column(
                              children: [
                                _MapControl(
                                  icon: Icons.add_rounded,
                                  tooltip: 'Zoom in',
                                  onTap: () => unawaited(
                                    _mapController?.animateCamera(
                                      CameraUpdate.zoomIn(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _MapControl(
                                  icon: Icons.remove_rounded,
                                  tooltip: 'Zoom out',
                                  onTap: () => unawaited(
                                    _mapController?.animateCamera(
                                      CameraUpdate.zoomOut(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _MapControl(
                                  icon: Icons.my_location_rounded,
                                  tooltip: 'Use my current location',
                                  onTap: () => unawaited(_useCurrentLocation()),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.elevated,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: pickerState.resolving
                          ? const Row(
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text('Confirming selected location…'),
                                ),
                              ],
                            )
                          : Text(
                              selected?.displayAddress.isNotEmpty ?? false
                                  ? selected!.displayAddress
                                  : 'Search for a place or tap the map to choose a location.',
                              style: context.pMuted,
                            ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _nameController,
                    maxLength: 140,
                    decoration: const InputDecoration(
                      labelText: 'Location name',
                      hintText: 'e.g. TechHub Main Shop',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _instructionsController,
                    maxLength: 500,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Directions note',
                      hintText:
                          'Optional landmark, floor or entrance instructions',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: busy || selected == null ? null : _save,
                    style: FilledButton.styleFrom(
                      foregroundColor: colors.white,
                    ),
                    icon: Icon(Icons.location_on_outlined, color: colors.white),
                    label: Text(
                      'Save Location',
                      style: AppTextStylesX(
                        context,
                      ).button.copyWith(color: colors.white),
                    ),
                  ),
                  if (locationState.location != null) ...[
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: busy ? null : _remove,
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Remove Location'),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

class _MapControl extends StatelessWidget {
  const _MapControl({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.surface.withValues(alpha: .94),
      elevation: 3,
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onTap,
        icon: Icon(icon, color: colors.primary),
      ),
    );
  }
}
