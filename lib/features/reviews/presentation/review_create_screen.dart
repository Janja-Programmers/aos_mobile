import 'dart:io';

import 'package:africaonlinestores/core/files/data/files_api_provider.dart';
import 'package:africaonlinestores/core/files/helpers/media_helper.dart';
import 'package:africaonlinestores/core/files/helpers/review_media_helper.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/reviews/application/controllers/review_create_controller.dart';
import 'package:africaonlinestores/features/reviews/presentation/widgets/image_picker_bottom_sheet.dart';
import 'package:africaonlinestores/shared/components/buttons/primary_button.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  double _rating = 0.0;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl.addListener(_refreshFormState);
    _commentCtrl.addListener(_refreshFormState);
  }

  void _refreshFormState() {
    if (mounted) setState(() {});
  }

  Future<void> _pickImages() async {
    final availableSlots = ReviewMediaHelper.maxImages - _images.length;

    if (availableSlots <= 0) {
      ShowSnack(
        context,
        'Maximum ${ReviewMediaHelper.maxImages} images allowed',
      ).error();
      return;
    }

    final selection = await showImageSourcePicker(
      context,
      availableSlots: availableSlots,
    );

    if (!mounted || selection == null) return;

    final existingPaths = _images.map((file) => file.path).toSet();
    final uniqueFiles = selection.files.where((file) {
      return existingPaths.add(file.path);
    }).toList();
    final filesToAdd = uniqueFiles.take(availableSlots).toList();

    if (filesToAdd.isNotEmpty) {
      setState(() => _images.addAll(filesToAdd));
    }

    if (selection.exceededAvailableSlots ||
        uniqueFiles.length > availableSlots) {
      ShowSnack(
        context,
        'Only $availableSlots more ${availableSlots == 1 ? 'image was' : 'images were'} added. The maximum is ${ReviewMediaHelper.maxImages}.',
      ).error();
    } else if (filesToAdd.length < selection.files.length) {
      ShowSnack(context, 'Duplicate images were not added.').error();
    }
  }

  Future<void> _submit() async {
    if (_uploading) return;

    if (_rating == 0) {
      ShowSnack(context, 'Please select a rating').error();
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    if (_images.length > ReviewMediaHelper.maxImages) {
      ShowSnack(
        context,
        'Maximum ${ReviewMediaHelper.maxImages} images allowed',
      ).error();
      return;
    }

    setState(() => _uploading = true);

    try {
      final uploadedFiles = await MediaHelper.uploadMultiple(
        ref: ref,
        files: _images,
        uploadFn: (file) {
          return ref.read(filesApiProvider).uploadMedia(file: file);
        },
      );

      if (!mounted) return;

      final imageUrls = uploadedFiles
          .map((file) => file.url.trim())
          .where((url) => url.isNotEmpty)
          .toList();

      if (imageUrls.length != _images.length) {
        ShowSnack(
          context,
          'Some images could not be uploaded. Please try again.',
        ).error();
        return;
      }

      final controller = ref.read(
        reviewCreateControllerProvider(widget.adId).notifier,
      );

      final success = await controller.submit(
        rating: _rating,
        title: _titleCtrl.text.trim(),
        comment: _commentCtrl.text.trim(),
        images: imageUrls,
      );

      if (!mounted) return;

      final createState = ref.read(reviewCreateControllerProvider(widget.adId));

      if (success) {
        ShowSnack(context, 'Review submitted successfully').success();
        Navigator.pop(context, true);
      } else {
        ShowSnack(context, createState.error ?? 'Something went wrong').error();
      }
    } catch (_) {
      if (mounted) {
        ShowSnack(
          context,
          'Unable to submit the review. Please try again.',
        ).error();
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

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
    }
  }

  bool get _canSubmit {
    return _rating > 0 &&
        _titleCtrl.text.trim().isNotEmpty &&
        _commentCtrl.text.trim().isNotEmpty;
  }

  InputDecoration _dec(BuildContext context, {required String hint}) {
    return InputDecoration(
      hintText: hint,
    ).applyDefaults(Theme.of(context).inputDecorationTheme);
  }

  Widget _buildStars() {
    final colors = context.appColors;

    return Row(
      children: List.generate(5, (index) {
        final star = index + 1;

        return IconButton(
          tooltip: '$star star${star == 1 ? '' : 's'}',
          onPressed: () => setState(() => _rating = star.toDouble()),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          icon: Icon(
            _rating >= star ? Icons.star_rounded : Icons.star_border_rounded,
            size: 32,
            color: colors.warning,
          ),
        );
      }),
    );
  }

  Widget _buildImagePreview() {
    final colors = context.appColors;
    if (_images.isEmpty) return const SizedBox.shrink();

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
              child: Material(
                color: colors.black.withValues(alpha: 0.6),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => setState(() => _images.remove(file)),
                  child: Padding(
                    padding: const EdgeInsets.all(7),
                    child: Icon(Icons.close, size: 16, color: colors.white),
                  ),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final createState = ref.watch(reviewCreateControllerProvider(widget.adId));
    final isBusy = _uploading || createState.submitting;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(title: Text('Review', style: context.h5)),
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
                      Text('Overall Ratings', style: context.pStrong),
                      const SizedBox(height: 12),
                      _buildStars(),
                      const SizedBox(height: 20),
                      Text('Review Title', style: context.pStrong),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleCtrl,
                        decoration: _dec(context, hint: 'Example: Easy to use'),
                        validator: (value) {
                          return value == null || value.trim().isEmpty
                              ? 'Title required'
                              : null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Text('Review Detail', style: context.pStrong),
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
                        validator: (value) {
                          return value == null || value.trim().isEmpty
                              ? 'Comment required'
                              : null;
                        },
                      ),
                      Text(
                        '${_commentCtrl.text.length}/200',
                        style: context.pMuted,
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: isBusy ? null : _pickImages,
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.camera_alt_outlined),
                              const SizedBox(width: 8),
                              Text(
                                'Add photos (${_images.length}/${ReviewMediaHelper.maxImages})',
                                style: context.p,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildImagePreview(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: PrimaryButton(
                text: 'Submit',
                loading: isBusy,
                onPressed: _canSubmit && !isBusy ? _submit : null,
                onDisabledTap: isBusy ? null : _handleDisabledTap,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleCtrl.removeListener(_refreshFormState);
    _commentCtrl.removeListener(_refreshFormState);
    _titleCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }
}
