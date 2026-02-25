import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/shared/components/app_text_styles.dart';
import 'package:africaonlinestores/shared/components/buttons/primary_button.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key, required this.adId});

  final String adId;

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _commentCtrl = TextEditingController();

  double _rating = 0.0;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _commentCtrl.addListener(() {
      setState(() {});
    });
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ShowSnack(context, 'Please select a rating').error();
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final res = await ref
        .read(adsApiProvider)
        .createAdReview(
          ad: widget.adId,
          rating: _rating,
          title: _titleCtrl.text.trim(),
          comment: _commentCtrl.text.trim(),
        );

    setState(() => _loading = false);

    res.fold((failure) => ShowSnack(context, failure.message).error(), (_) {
      ShowSnack(context, 'Review submitted successfully').success();
      Navigator.pop(context, true); // return true for refresh
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
            size: 30,
            color: colors.warning,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back),
        title: Text("Review", style: context.h5),
      ),
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
                      /// Overall Ratings
                      Text("Overall Ratings", style: context.pStrong),
                      const SizedBox(height: 12),

                      buildInteractiveStars(),

                      const SizedBox(height: 20),

                      /// Review Title
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

                      /// Review Detail
                      Text("Review Detail", style: context.pStrong),
                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _commentCtrl,
                        maxLines: 4,
                        maxLength: 200,
                        decoration: const InputDecoration(
                          fillColor: Colors.transparent,
                          hintText:
                              'The Calla lounge chair has a stylish design with functional armrests.',
                          counterText: "", // hides default counter
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Comment required'
                            : null,
                      ),

                      /// Custom Counter Bottom Left
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "${_commentCtrl.text.length}/200",
                          style: context.pMuted,
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// Add Photo Row
                      InkWell(
                        onTap: () {
                          // TODO: implement image picker
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.camera_alt_outlined, size: 20),
                            const SizedBox(width: 8),
                            Text("Add a photo", style: context.p),
                          ],
                        ),
                      ),
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
