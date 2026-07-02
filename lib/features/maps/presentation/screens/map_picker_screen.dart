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
  final _searchController = TextEditingController();
  Timer? _debounce;
  MapLibreMapController? _mapController;

  static const _fallbackCenter = LatLng(-4.0435, 39.6682);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final initial = widget.initialPlace;
      if (initial != null) {
        ref.read(mapPickerControllerProvider.notifier).selectPlace(initial);
      }
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
      ref.read(mapPickerControllerProvider.notifier).search(value);
    });
  }

  Future<void> _moveToPlace(AOSPlace place) async {
    await _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(place.latitude, place.longitude), 15),
    );
  }

  Future<void> _confirm() async {
    final selected = ref.read(mapPickerControllerProvider).selected;
    if (selected == null) {
      ShowSnack(context, 'Choose a location first.').info();
      return;
    }
    context.pop(selected);
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
      appBar: AppBar(
        title: Text(widget.title, style: context.h5),
        actions: [
          TextButton(
            onPressed: _confirm,
            child: Text('Done', style: context.pStrong),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: MapLibreMap(
              styleString: AppConfig.mapStyleUrl,
              initialCameraPosition: CameraPosition(target: target, zoom: 13),
              myLocationEnabled: true,
              onMapCreated: (controller) => _mapController = controller,
              onMapClick: (_, point) {
                ref
                    .read(mapPickerControllerProvider.notifier)
                    .selectCoordinates(point.latitude, point.longitude);
              },
            ),
          ),
          const Center(
            child: IgnorePointer(
              child: Icon(Icons.location_pin, size: 42, color: Colors.red),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            top: 12,
            child: Material(
              color: colors.surface,
              elevation: 8,
              borderRadius: BorderRadius.circular(18),
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
                              icon: const Icon(Icons.my_location_rounded),
                              onPressed: () => ref
                                  .read(mapPickerControllerProvider.notifier)
                                  .useCurrentLocation(),
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
                        separatorBuilder: (_, _) =>
                            Divider(height: 1, color: colors.border),
                        itemBuilder: (_, index) {
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
                            onTap: () async {
                              ref
                                  .read(mapPickerControllerProvider.notifier)
                                  .selectPlace(place);
                              _searchController.text = place.shortLabel;
                              await _moveToPlace(place);
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 16,
            child: SafeArea(
              top: false,
              child: _SelectedLocationCard(
                place: selected,
                resolving: state.resolving,
                onUseCurrent: () => ref
                    .read(mapPickerControllerProvider.notifier)
                    .useCurrentLocation(),
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
    required this.onUseCurrent,
    required this.onConfirm,
  });

  final AOSPlace? place;
  final bool resolving;
  final VoidCallback onUseCurrent;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: colors.surface,
      elevation: 10,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: colors.primary.withValues(alpha: .12),
                  child: resolving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(Icons.location_on_rounded, color: colors.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place?.shortLabel ?? 'Move map or search to choose',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.pStrong,
                      ),
                      if (place != null)
                        Text(
                          place!.displayAddress,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.small.copyWith(
                            color: colors.textMuted,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onUseCurrent,
                    icon: const Icon(Icons.my_location_rounded),
                    label: const Text('Current'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    child: const Text('Use location'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
