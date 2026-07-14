import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/media/data/media_upload_api_provider.dart';
import 'package:africaonlinestores/core/media/domain/media_upload_purpose.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/features/sellers/application/controllers/operating_hours_form.dart';
import 'package:africaonlinestores/features/sellers/application/providers/seller_state_controller_provider.dart';
import 'package:africaonlinestores/features/sellers/domain/aos_seller.dart';
import 'package:africaonlinestores/features/sellers/navigation/seller_routes.dart';
import 'package:africaonlinestores/features/sellers/presentation/widgets/store_customization/store_banner_picker.dart';
import 'package:africaonlinestores/features/sellers/presentation/widgets/store_customization/store_description_field.dart';
import 'package:africaonlinestores/features/sellers/presentation/widgets/store_customization/store_image_source_sheet.dart';
import 'package:africaonlinestores/features/sellers/presentation/widgets/store_customization/widgets.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StoreCustomizationScreen extends ConsumerStatefulWidget {
  const StoreCustomizationScreen({super.key, required this.sellerId});

  final String sellerId;

  @override
  ConsumerState<StoreCustomizationScreen> createState() =>
      _StoreCustomizationScreenState();
}

class _StoreCustomizationScreenState
    extends ConsumerState<StoreCustomizationScreen> {
  final _categoryCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  late final OperatingHoursForm _hoursForm;

  String? _uploadedShopBannerMediaId;
  String? _uploadedShopBannerPreview;

  bool _changed = false;
  bool _saving = false;
  bool _uploading = false;
  bool _initializedFromSeller = false;

  @override
  void initState() {
    super.initState();

    _hoursForm = OperatingHoursForm();

    final seller = ref.read(sellerStateProvider(widget.sellerId)).seller;
    if (seller != null) {
      _hydrateFields(seller);
      _initializedFromSeller = true;
    }

    _categoryCtrl.addListener(_markChanged);
    _descCtrl.addListener(_markChanged);
  }

  @override
  void dispose() {
    _categoryCtrl
      ..removeListener(_markChanged)
      ..dispose();
    _descCtrl
      ..removeListener(_markChanged)
      ..dispose();
    super.dispose();
  }

  void _markChanged() {
    if (!_changed && mounted) {
      setState(() => _changed = true);
    }
  }

  void _setCategorySilently(String value) {
    _categoryCtrl.removeListener(_markChanged);
    _categoryCtrl.text = value;
    _categoryCtrl.addListener(_markChanged);
  }

  void _setDescriptionSilently(String value) {
    _descCtrl.removeListener(_markChanged);
    _descCtrl.text = value;
    _descCtrl.addListener(_markChanged);
  }

  void _hydrateFields(AOSSellerProfile seller) {
    _setCategorySilently(seller.businessCategory ?? '');
    _setDescriptionSilently(seller.aboutBusiness ?? '');
    _hoursForm.hydrate(seller.operatingHours);
  }

  void _hydrateFromSeller(AOSSellerProfile seller) {
    if (_initializedFromSeller) return;

    _hydrateFields(seller);
    _initializedFromSeller = true;
  }

  Future<void> _pickAndUploadBanner() async {
    if (_saving || _uploading) return;

    final file = await showStoreImageSourceSheet(context);
    if (!mounted || file == null) return;

    setState(() => _uploading = true);

    final uploaded = await ref
        .read(mediaUploadApiProvider)
        .uploadMedia(file: file, purpose: MediaUploadPurpose.sellerBanner);

    if (!mounted) return;

    uploaded.fold(
      (failure) {
        setState(() => _uploading = false);
        ShowSnack(context, failure.message).error();
      },
      (media) {
        setState(() {
          _uploadedShopBannerMediaId = media.mediaId;
          _uploadedShopBannerPreview = media.url;
          _changed = true;
          _uploading = false;
        });
      },
    );
  }

  Future<void> _pickOpenTime(String day) async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          _hoursForm.openTimes[day] ?? const TimeOfDay(hour: 9, minute: 0),
    );

    if (!mounted || picked == null) return;

    setState(() {
      _hoursForm.openTimes[day] = picked;
      _changed = true;
    });
  }

  Future<void> _pickCloseTime(String day) async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          _hoursForm.closeTimes[day] ?? const TimeOfDay(hour: 18, minute: 0),
    );

    if (!mounted || picked == null) return;

    setState(() {
      _hoursForm.closeTimes[day] = picked;
      _changed = true;
    });
  }

  void _onDayChanged(String day, bool enabled) {
    setState(() {
      _hoursForm.dayEnabled[day] = enabled;
      _changed = true;
    });
  }

  Future<void> _openLocationEditor() async {
    if (_saving || _uploading) return;

    await SellerNavigation.toSellerLocation(context);
    if (!mounted) return;

    await ref.read(sellerStateProvider(widget.sellerId).notifier).load();
  }

  Future<void> _save() async {
    if (_saving || _uploading) return;

    setState(() => _saving = true);

    try {
      final error = await ref
          .read(sellerStateProvider(widget.sellerId).notifier)
          .updateSellerProfile(
            businessCategory: _categoryCtrl.text.trim(),
            aboutBusiness: _descCtrl.text.trim(),
            shopBanner: _uploadedShopBannerMediaId,
            operatingHours: _hoursForm.toApiPayload(),
          );

      if (!mounted) return;

      if (error != null) {
        ShowSnack(context, error).error();
        return;
      }

      ShowSnack(context, 'Updated successfully').success();

      setState(() {
        _changed = false;
        _uploadedShopBannerMediaId = null;
        _uploadedShopBannerPreview = null;
      });

      await Future<void>.delayed(const Duration(milliseconds: 300));

      if (mounted) Navigator.pop(context, true);
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final seller = ref.watch(sellerStateProvider(widget.sellerId)).seller;
    final colors = context.appColors;

    if (seller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    _hydrateFromSeller(seller);

    final bannerUri = _uploadedShopBannerPreview ?? seller.shopBanner;
    final banner = buildFileUrl(bannerUri);

    return Scaffold(
      appBar: AppBar(
        title: Text('Store Customization', style: context.h5),
        actions: [
          TextButton(
            onPressed: (_changed && !_saving && !_uploading) ? _save : null,
            child: _saving
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Save',
                    style: context.body.copyWith(
                      color: _changed && !_uploading
                          ? colors.primary
                          : colors.textPrimary,
                    ),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
          children: [
            const SectionTitle(
              icon: Icons.account_circle_outlined,
              label: 'Store Banner',
            ),
            const SizedBox(height: 14),
            StoreBannerPicker(
              bannerUrl: banner,
              uploading: _uploading,
              onTap: _pickAndUploadBanner,
            ),
            const SizedBox(height: 28),
            const SectionTitle(
              icon: Icons.category_outlined,
              label: 'Business Category',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _categoryCtrl,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: 'Example: Electronics, Fashion, Food',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const SectionTitle(
              icon: Icons.location_on_outlined,
              label: 'Store Location',
            ),
            const SizedBox(height: 12),
            _StoreLocationCard(
              location: seller.location,
              onTap: _openLocationEditor,
            ),
            const SizedBox(height: 24),
            const SectionTitle(
              icon: Icons.description_outlined,
              label: 'Store Description',
            ),
            const SizedBox(height: 12),
            StoreDescriptionField(controller: _descCtrl),
            const SizedBox(height: 20),
            const SectionTitle(
              icon: Icons.access_time,
              label: 'Operating Hours',
            ),
            const SizedBox(height: 12),
            OperatingHoursSection(
              dayEnabled: _hoursForm.dayEnabled,
              openTimes: _hoursForm.openTimes,
              closeTimes: _hoursForm.closeTimes,
              onDayChanged: _onDayChanged,
              onOpenTimeTap: _pickOpenTime,
              onCloseTimeTap: _pickCloseTime,
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  SellerNavigation.toSellerStore(context, widget.sellerId);
                },
                icon: Icon(
                  Icons.remove_red_eye_outlined,
                  color: colors.primary,
                ),
                label: Text(
                  'Preview Storefront',
                  style: context.p.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreLocationCard extends StatelessWidget {
  const _StoreLocationCard({required this.location, required this.onTap});

  final AOSSellerLocation? location;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasLocation = location != null;
    final title = hasLocation ? location!.title : 'Add store location';
    final subtitle = hasLocation
        ? location!.subtitle ?? 'Location saved'
        : 'Let buyers find your shop or pickup point.';
    final instructions = location?.instructions?.trim();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: .1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.store_mall_directory_outlined,
                color: colors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.pStrong.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.smallMuted,
                  ),
                  if (instructions != null && instructions.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      instructions,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.small.copyWith(color: colors.textPrimary),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              hasLocation ? 'Edit' : 'Add',
              style: context.small.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, color: colors.textMuted),
          ],
        ),
      ),
    );
  }
}
