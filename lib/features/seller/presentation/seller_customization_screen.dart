import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/seller/providers/seller_state_controller_provider.dart';

import 'package:africaonlinestores/shared/components/app_circle_avatar.dart';
import 'package:africaonlinestores/core/files/helpers/review_media_helper.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';

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

  String? _uploadedAvatar;
  bool _changed = false;
  bool _saving = false;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();

    final seller = ref.read(sellerStateProvider(widget.sellerId)).seller;

    if (seller != null) {
      _descCtrl.text = seller.aboutShop ?? '';
    }

    _descCtrl.addListener(() {
      setState(() => _changed = true);
    });
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<File?> _showPicker() async {
    return showModalBottomSheet<File?>(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Gallery"),
                onTap: () async {
                  final file = await ReviewMediaHelper.pickFromGallery();
                  if (mounted) Navigator.pop(context, file);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: () async {
                  final file = await ReviewMediaHelper.takePhoto();
                  if (mounted) Navigator.pop(context, file);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadAvatar() async {
    if (_saving) return;

    setState(() => _uploading = true);

    /// 1️⃣ pick image
    final file = await _showPicker();

    if (file == null) {
      if (mounted) setState(() => _uploading = false);
      return;
    }

    /// 2️⃣ upload
    final urls = await ReviewMediaHelper.upload(ref: ref, files: [file]);

    if (!mounted) return;

    if (urls.isEmpty) {
      setState(() => _uploading = false);
      ShowSnack(context, "Upload failed").error();
      return;
    }

    /// 3️⃣ update UI
    setState(() {
      _uploadedAvatar = urls.first;
      _changed = true;
      _uploading = false;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    try {
      final error = await ref
          .read(sellerStateProvider(widget.sellerId).notifier)
          .updateSellerProfile(
            aboutShop: _descCtrl.text,
            avatar: _uploadedAvatar,
          );

      if (!mounted) return;

      if (error != null) {
        ShowSnack(context, error).error();
      } else {
        ShowSnack(context, "Updated successfully").success();

        await Future.delayed(const Duration(milliseconds: 300));

        if (mounted) Navigator.pop(context, true);
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final seller = ref.watch(sellerStateProvider(widget.sellerId)).seller;

    final isCreate = seller == null;
    final colors = context.appColors;

    if (seller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final avatar = _uploadedAvatar ?? seller.avatar;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isCreate ? "Create Store" : "Store Customization",
          style: context.h5,
        ),
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
                    _saving ? "Saving..." : "Save",
                    style: context.body.copyWith(
                      color: _saving ? colors.textPrimary : colors.primary,
                    ),
                  ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// LOGO
          const Text("Store Logo", style: TextStyle(fontSize: 16)),

          const SizedBox(height: 12),

          Center(
            child: GestureDetector(
              onTap: _uploading ? null : _pickAndUploadAvatar,
              child: Column(
                children: [
                  _uploading
                      ? const SizedBox(
                          height: 80,
                          width: 80,
                          child: CircularProgressIndicator(),
                        )
                      : AppCircularAvatar(
                          name: seller.shopName,
                          imageUrl: avatar,
                          radius: 40,
                        ),
                  const SizedBox(height: 8),
                  Text(_uploading ? "Uploading..." : "Add Logo"),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          /// DESCRIPTION
          const Text("Store Description"),

          const SizedBox(height: 8),

          TextField(
            controller: _descCtrl,
            maxLength: 500,
            maxLines: 5,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 24),

          /// SOCIAL (DISPLAY ONLY)
          const Text("Social Media Links"),

          const SizedBox(height: 12),

          const Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _SocialChip(label: "Instagram"),
              _SocialChip(label: "Facebook"),
              _SocialChip(label: "Twitter"),
              _SocialChip(label: "WhatsApp", selected: true),
              _SocialChip(label: "YouTube"),
              _SocialChip(label: "TikTok"),
            ],
          ),

          const SizedBox(height: 32),

          /// PREVIEW BUTTON
          OutlinedButton.icon(
            onPressed: null,
            icon: Icon(Icons.remove_red_eye, color: colors.primary),
            label: Text("Preview Storefront", style: context.body),
          ),
        ],
      ),
    );
  }
}

/// TEMP social chip (no logic yet)
class _SocialChip extends StatelessWidget {
  const _SocialChip({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: selected ? Colors.red : Colors.grey.shade300),
      ),
      child: Text(label),
    );
  }
}
