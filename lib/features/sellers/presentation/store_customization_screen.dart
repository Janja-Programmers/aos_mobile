import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/files/helpers/review_media_helper.dart';
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
  final _descCtrl = TextEditingController();
  late final OperatingHoursForm _hoursForm;

  String? _uploadedShopBanner;

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
      _setDescriptionSilently(seller.aboutBusiness ?? '');
      _hoursForm.hydrate(seller.operatingHours);
      _initializedFromSeller = true;
    }

    _descCtrl.addListener(_markChanged);
  }

  @override
  void dispose() {
    _descCtrl.removeListener(_markChanged);
    _descCtrl.dispose();
    super.dispose();
  }

  void _markChanged() {
    if (!_changed) {
      setState(() => _changed = true);
    }
  }

  void _setDescriptionSilently(String value) {
    _descCtrl.removeListener(_markChanged);
    _descCtrl.text = value;
    _descCtrl.addListener(_markChanged);
  }

  void _hydrateFromSeller(AOSSellerProfile seller) {
    if (_initializedFromSeller) return;

    _setDescriptionSilently(seller.aboutBusiness ?? '');
    _hoursForm.hydrate(seller.operatingHours);

    _initializedFromSeller = true;
  }

  Future<void> _pickAndUploadBanner() async {
    if (_saving || _uploading) return;

    final file = await showStoreImageSourceSheet(context);

    if (file == null) return;

    setState(() => _uploading = true);

    final urls = await ReviewMediaHelper.upload(ref: ref, files: [file]);

    if (!mounted) return;

    if (urls.isEmpty) {
      setState(() => _uploading = false);
      ShowSnack(context, 'Upload failed').error();
      return;
    }

    setState(() {
      _uploadedShopBanner = urls.first;
      _changed = true;
      _uploading = false;
    });
  }

  Future<void> _pickOpenTime(String day) async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          _hoursForm.openTimes[day] ?? const TimeOfDay(hour: 9, minute: 0),
    );

    if (picked == null) return;

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

    if (picked == null) return;

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

  Future<void> _save() async {
    if (_saving || _uploading) return;

    setState(() => _saving = true);

    try {
      final error = await ref
          .read(sellerStateProvider(widget.sellerId).notifier)
          .updateSellerProfile(
            aboutBusiness: _descCtrl.text.trim(),
            shopBanner: _uploadedShopBanner,
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
        _uploadedShopBanner = null;
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

    final bannerUri = _uploadedShopBanner ?? seller.shopBanner;
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

      body: ListView(
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
            icon: Icons.description_outlined,
            label: 'Store Description',
          ),

          const SizedBox(height: 12),

          StoreDescriptionField(controller: _descCtrl),

          const SizedBox(height: 20),

          const SectionTitle(icon: Icons.access_time, label: 'Operating Hours'),

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
              icon: Icon(Icons.remove_red_eye_outlined, color: colors.primary),
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
    );
  }
}
