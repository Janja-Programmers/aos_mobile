import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/files/data/files_api_provider.dart';
import 'package:africaonlinestores/features/reviews/application/controllers/review_create_controller.dart';
import 'package:africaonlinestores/features/reviews/presentation/widgets/image_picker_bottom_sheet.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/shared/components/buttons/primary_button.dart';
import 'package:africaonlinestores/core/files/helpers/media_helper.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';

class ReviewCreateScreen extends ConsumerStatefulWidget {
  const ReviewCreateScreen({super.key, required this.adId});

  final String adId;

  @override
  ConsumerState<ReviewCreateScreen> createState() => _ReviewCreateScreenState();
}

class _ReviewCreateScreenState extends ConsumerState<ReviewCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleCtrl = TextEditingController();
  final _commentCtrl = TextEditingController();

  final List<File> _images = [];

  static const int maxImages = 4;

  double _rating = 0.0;

  @override
  void initState() {
    super.initState();
    _commentCtrl.addListener(() => setState(() {}));
  }

  // -------------------------
  // PICK IMAGE
  // -------------------------

  Future<void> _pickImage() async {
    if (_images.length >= maxImages) {
      ShowSnack(context, 'Maximum $maxImages images allowed').error();
      return;
    }

    final file = await showImageSourcePicker(context);
    if (file == null) return;

    setState(() => _images.add(file));
  }

  // -------------------------
  // SUBMIT
  // -------------------------

  Future<void> _submit() async {
    if (_rating == 0) {
      ShowSnack(context, 'Please select a rating').error();
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final ctrl = ref.read(reviewCreateControllerProvider(widget.adId).notifier);

    // ✅ Upload using new MediaHelper
    final uploadedFiles = await MediaHelper.uploadMultiple(
      ref: ref,
      files: _images,
      uploadFn: (file) => ref.read(filesApiProvider).uploadMedia(file: file),
    );

    final imageUrls = uploadedFiles.map((e) => e.url).toList();

    final success = await ctrl.submit(
      rating: _rating,
      title: _titleCtrl.text.trim(),
      comment: _commentCtrl.text.trim(),
      images: imageUrls,
    );

    final state = ref.read(reviewCreateControllerProvider(widget.adId));

    if (!mounted) return;

    if (success) {
      ShowSnack(context, 'Review submitted successfully').success();
      Navigator.pop(context, true);
    } else {
      ShowSnack(context, state.error ?? 'Something went wrong').error();
    }
  }

  // -------------------------
  // DISABLED TAP HANDLER
  // -------------------------

  void _handleDisabledTap() {
    if (_rating == 0) {
      ShowSnack(context, 'Please select a rating').error();
      return;
    }

    if (_titleCtrl.text.trim().isEmpty) {
      ShowSnack(context, 'Title required').error();
      return;
    }

    if (_commentCtrl.text.trim().isEmpty) {
      ShowSnack(context, 'Review Detail required').error();
      return;
    }
  }

  bool get _canSubmit =>
      _rating > 0 &&
      _titleCtrl.text.trim().isNotEmpty &&
      _commentCtrl.text.trim().isNotEmpty;

  InputDecoration _dec(BuildContext context, {required String hint}) {
    return InputDecoration(
      hintText: hint,
    ).applyDefaults(Theme.of(context).inputDecorationTheme);
  }

  // -------------------------
  // STARS
  // -------------------------

  Widget buildStars() {
    final colors = context.appColors;

    return Row(
      children: List.generate(5, (i) {
        final index = i + 1;

        return GestureDetector(
          onTap: () => setState(() => _rating = index.toDouble()),
          child: Icon(
            _rating >= index ? Icons.star_rounded : Icons.star_border_rounded,
            size: 32,
            color: colors.warning,
          ),
        );
      }),
    );
  }

  // -------------------------
  // IMAGE PREVIEW
  // -------------------------

  Widget _preview() {
    final colors = context.appColors;
    if (_images.isEmpty) return const SizedBox();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _images.map((file) {
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(file, width: 80, height: 80, fit: BoxFit.cover),
            ),
            Positioned(
              right: 2,
              top: 2,
              child: GestureDetector(
                onTap: () => setState(() => _images.remove(file)),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colors.black.withOpacity(0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(Icons.close, size: 16, color: colors.white),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  // -------------------------
  // BUILD
  // -------------------------

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final state = ref.watch(reviewCreateControllerProvider(widget.adId));

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(title: Text("Review", style: context.h5)),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Overall Ratings", style: context.pStrong),
                      const SizedBox(height: 12),
                      buildStars(),

                      const SizedBox(height: 20),

                      Text("Review Title", style: context.pStrong),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleCtrl,
                        decoration: _dec(context, hint: 'Example: Easy to use'),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Title required'
                            : null,
                      ),

                      const SizedBox(height: 20),

                      Text("Review Detail", style: context.pStrong),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _commentCtrl,
                        maxLines: 4,
                        maxLength: 200,
                        decoration: _dec(
                          context,
                          hint:
                              'The product has a stylish design and works perfectly.',
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Comment required'
                            : null,
                      ),

                      Text(
                        "${_commentCtrl.text.length}/200",
                        style: context.pMuted,
                      ),

                      const SizedBox(height: 16),

                      InkWell(
                        onTap: _pickImage,
                        child: Row(
                          children: [
                            const Icon(Icons.camera_alt_outlined),
                            const SizedBox(width: 8),
                            Text("Add a photo", style: context.p),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),
                      _preview(),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: PrimaryButton(
              text: "Submit",
              loading: state.submitting,
              onPressed: _canSubmit ? _submit : null,
              onDisabledTap: _handleDisabledTap,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }
}
