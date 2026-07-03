import 'dart:async';

import 'package:africaonlinestores/core/config/app_config.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/maps/application/map_picker_controller.dart';
import 'package:africaonlinestores/features/maps/domain/aos_place.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class MapPickerScreen extends ConsumerStatefulWidget {
  const MapPickerScreen({
    super.key,
    this.title = 'Choose location',
    this.initialPlace,
  });

  final String title;
  final AOSPlace? initialPlace;

  @override
  ConsumerState<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends ConsumerState<MapPickerScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  MapLibreMapController? _mapController;

  static const LatLng _fallbackCenter = LatLng(-4.0435, 39.6682);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final initial = widget.initialPlace;
      if (!mounted || initial == null) return;
      ref.read(mapPickerControllerProvider.notifier).selectPlace(initial);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      unawaited(ref.read(mapPickerControllerProvider.notifier).search(value));
    });
  }

  Future<void> _moveToPlace(AOSPlace place) async {
    await _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(place.latitude, place.longitude), 15),
    );
  }

  void _confirm() {
    final selected = ref.read(mapPickerControllerProvider).selected;
    if (selected == null) {
      ShowSnack(context, 'Choose a location first.').info();
      return;
    }
    context.pop(selected);
  }

  Future<void> _selectSearchResult(AOSPlace place) async {
    ref.read(mapPickerControllerProvider.notifier).selectPlace(place);
    _searchController.text = place.shortLabel;
    await _moveToPlace(place);
  }

  void _useCurrentLocation() {
    unawaited(
      ref.read(mapPickerControllerProvider.notifier).useCurrentLocation(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final state = ref.watch(mapPickerControllerProvider);
    final selected = state.selected ?? widget.initialPlace;
    final target = selected == null
        ? _fallbackCenter
        : LatLng(selected.latitude, selected.longitude);

    ref.listen(mapPickerControllerProvider.select((s) => s.error), (
      prev,
      next,
    ) {
      if (next != null && next != prev && mounted) {
        ShowSnack(context, next).error();
      }
    });

    return Scaffold(
      backgroundColor: colors.surface,
      body: Stack(
        children: [
          Positioned.fill(
            child: MapLibreMap(
              styleString: AppConfig.mapStyleUrl,
              initialCameraPosition: CameraPosition(target: target, zoom: 13),
              myLocationEnabled: true,
              onMapCreated: (controller) => _mapController = controller,
              onMapClick: (point, coordinates) {
                unawaited(
                  ref
                      .read(mapPickerControllerProvider.notifier)
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
              child: Icon(Icons.location_pin, size: 52, color: Colors.red),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FloatingMapButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'Back',
                    onTap: () => context.pop(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Material(
                      color: colors.surface.withValues(alpha: 0.94),
                      elevation: 10,
                      borderRadius: BorderRadius.circular(22),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search_rounded),
                              hintText: 'Search places',
                              suffixIcon: state.loading
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
                                  : IconButton(
                                      icon: const Icon(
                                        Icons.my_location_rounded,
                                      ),
                                      onPressed: _useCurrentLocation,
                                    ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 15,
                                horizontal: 12,
                              ),
                            ),
                          ),
                          if (state.results.isNotEmpty)
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 240),
                              child: ListView.separated(
                                shrinkWrap: true,
                                itemCount: state.results.length,
                                separatorBuilder: (context, index) =>
                                    Divider(height: 1, color: colors.border),
                                itemBuilder: (context, index) {
                                  final place = state.results[index];
                                  return ListTile(
                                    leading: const Icon(Icons.place_outlined),
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
                                    onTap: () {
                                      unawaited(_selectSearchResult(place));
                                    },
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 22,
            bottom: 184,
            child: SafeArea(
              top: false,
              child: _FloatingMapButton(
                icon: Icons.my_location_rounded,
                tooltip: 'Use current location',
                onTap: _useCurrentLocation,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: _SelectedLocationCard(
                place: selected,
                resolving: state.resolving,
                onConfirm: _confirm,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedLocationCard extends StatelessWidget {
  const _SelectedLocationCard({
    required this.place,
    required this.resolving,
    required this.onConfirm,
  });

  final AOSPlace? place;
  final bool resolving;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: colors.border)),
        boxShadow: [
          BoxShadow(
            color: colors.black.withValues(alpha: 0.24),
            blurRadius: 28,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(26, 22, 26, 26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: colors.primary.withValues(alpha: 0.16),
                  child: resolving
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.primary,
                          ),
                        )
                      : Icon(Icons.location_on_rounded, color: colors.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    place?.displayAddress ?? 'Move map or search to choose',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.pStrong.copyWith(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.send_rounded),
                label: const Text('Send this location'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingMapButton extends StatelessWidget {
  const _FloatingMapButton({
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

    return Tooltip(
      message: tooltip,
      child: Material(
        color: colors.black.withValues(alpha: 0.88),
        elevation: 10,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 54,
            height: 54,
            child: Icon(icon, color: colors.white, size: 26),
          ),
        ),
      ),
    );
  }
}
