import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/maps/domain/aos_place.dart';
import 'package:africaonlinestores/features/sellers/location/application/seller_location_controller.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';

class SellerLocationScreen extends ConsumerStatefulWidget {
  const SellerLocationScreen({super.key});

  @override
  ConsumerState<SellerLocationScreen> createState() =>
      _SellerLocationScreenState();
}

class _SellerLocationScreenState extends ConsumerState<SellerLocationScreen> {
  final _nameController = TextEditingController();
  final _instructionsController = TextEditingController();
  AOSPlace? _selected;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(sellerLocationControllerProvider.notifier).load();
      final location = ref.read(sellerLocationControllerProvider).location;
      if (location != null && mounted) {
        setState(() {
          _selected = location;
          _nameController.text = location.name;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _pickLocation() async {
    final picked = await context.pushNamed<AOSPlace>(
      AppRoutes.nMapPicker,
      queryParameters: {'title': 'Set store location'},
      extra: _selected,
    );

    if (picked == null || !mounted) return;
    setState(() {
      _selected = picked;
      if (_nameController.text.trim().isEmpty) {
        _nameController.text = picked.shortLabel;
      }
    });
  }

  Future<void> _save() async {
    final selected = _selected;
    if (selected == null) {
      ShowSnack(context, 'Choose your store location first.').info();
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
      ShowSnack(context, 'Seller location saved.').success();
      context.pop();
    } else {
      final error = ref.read(sellerLocationControllerProvider).error;
      ShowSnack(context, error ?? 'Failed to save location.').error();
    }
  }

  Future<void> _remove() async {
    final ok = await ref
        .read(sellerLocationControllerProvider.notifier)
        .remove();
    if (!mounted) return;
    if (ok) {
      setState(() => _selected = null);
      ShowSnack(context, 'Seller location removed.').success();
    } else {
      ShowSnack(context, 'Failed to remove location.').error();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final state = ref.watch(sellerLocationControllerProvider);

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(title: Text('Store location', style: context.h5)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Text(
              'Help buyers find your store or meeting point.',
              style: context.pMuted,
            ),
            const SizedBox(height: 16),
            _LocationPreview(
              place: _selected ?? state.location,
              onTap: _pickLocation,
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Location name',
                hintText: 'Example: AOS Mombasa Store',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _instructionsController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Directions / pickup instructions',
                hintText: 'Example: 2nd floor, ask for shop 12.',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: state.saving ? null : _save,
              icon: state.saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle_outline_rounded),
              label: const Text('Save location'),
            ),
            if ((state.location != null || _selected != null)) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: state.saving ? null : _remove,
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Remove saved location'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LocationPreview extends StatelessWidget {
  const _LocationPreview({required this.place, required this.onTap});

  final AOSPlace? place;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.elevated,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: colors.primary.withOpacity(.12),
              child: Icon(Icons.map_outlined, color: colors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place?.shortLabel ?? 'Choose location on map',
                    style: context.pStrong,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    place?.displayAddress ??
                        'Search, use current location, or tap on the map.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.smallMuted,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}
