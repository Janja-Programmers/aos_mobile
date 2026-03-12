import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/reviews/data/review_api.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ads_api_provider.dart';

import 'package:africaonlinestores/shared/components/buttons/primary_button.dart';
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

  final ImagePicker _picker = ImagePicker();

  final List<File> _images = [];

  double _rating = 0.0;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _commentCtrl.addListener(() => setState(() {}));
  }

  /// 📸 Pick Image
  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    setState(() {
      _images.add(File(picked.path));
    });
  }

  /// ☁ Upload Images
  Future<List<String>> _uploadImages() async {
    final urls = <String>[];

    for (final file in _images) {
      final res = await ref.read(adsApiProvider).uploadMedia(file: file);

      res.fold((_) {}, (data) {
        final url = data['file_url'];
        if (url != null) urls.add(url);
      });
    }

    return urls;
  }

  /// 🚀 Submit Review
  Future<void> _submit() async {
    if (_rating == 0) {
      ShowSnack(context, 'Please select a rating').error();
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final imageUrls = await _uploadImages();

    final res = await ref
        .read(reviewApiProvider)
        .createAdReview(
          ad: widget.adId,
          rating: _rating,
          title: _titleCtrl.text.trim(),
          comment: _commentCtrl.text.trim(),
          images: imageUrls,
        );

    setState(() => _loading = false);

    res.fold((failure) => ShowSnack(context, failure.message).error(), (_) {
      ShowSnack(context, 'Review submitted successfully').success();
      Navigator.pop(context, true);
    });
  }

  bool get _canSubmit =>
      _rating > 0 &&
      _titleCtrl.text.trim().isNotEmpty &&
      _commentCtrl.text.trim().isNotEmpty &&
      !_loading;

  /// ⭐ Interactive Stars
  Widget buildInteractiveStars() {
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

  /// 📷 Image Preview Grid
  Widget _buildImagePreview() {
    if (_images.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _images.map((file) {
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  file,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),

              /// remove image
              Positioned(
                right: 0,
                top: 0,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _images.remove(file);
                    });
                  },
                  child: const Icon(Icons.close, size: 18, color: Colors.red),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

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
                    color: colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// ⭐ Rating
                      Text("Overall Ratings", style: context.pStrong),
                      const SizedBox(height: 12),

                      buildInteractiveStars(),

                      const SizedBox(height: 20),

                      /// Title
                      Text("Review Title", style: context.pStrong),
                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _titleCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Example: Easy to use',
                          fillColor: Colors.transparent,
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Title required'
                            : null,
                      ),

                      const SizedBox(height: 20),

                      /// Comment
                      Text("Review Detail", style: context.pStrong),
                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _commentCtrl,
                        maxLines: 4,
                        maxLength: 200,
                        decoration: const InputDecoration(
                          fillColor: Colors.transparent,
                          hintText:
                              'The product has a stylish design and works perfectly.',
                          counterText: "",
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Comment required'
                            : null,
                      ),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "${_commentCtrl.text.length}/200",
                          style: context.pMuted,
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// 📷 Add Photo
                      InkWell(
                        onTap: _pickImage,
                        child: Row(
                          children: [
                            const Icon(Icons.camera_alt_outlined, size: 20),
                            const SizedBox(width: 8),
                            Text("Add a photo", style: context.p),
                          ],
                        ),
                      ),

                      _buildImagePreview(),
                    ],
                  ),
                ),
              ),
            ),
          ),

          /// Submit Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: PrimaryButton(
              text: "Submit",
              loading: _loading,
              onPressed: _canSubmit ? _submit : null,
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
