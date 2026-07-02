import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class StoreBannerPicker extends StatelessWidget {
  const StoreBannerPicker({
    super.key,
    required this.bannerUrl,
    required this.uploading,
    required this.onTap,
  });

  final String? bannerUrl;
  final bool uploading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasBanner = bannerUrl != null && bannerUrl!.isNotEmpty;

    return Center(
      child: GestureDetector(
        onTap: uploading ? null : onTap,
        child: Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: colors.border,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border),
            image: hasBanner
                ? DecorationImage(
                    image: NetworkImage(bannerUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: !hasBanner
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_photo_alternate_outlined),
                    const SizedBox(height: 6),
                    Text(
                      uploading ? 'Uploading...' : 'Add Store Banner',
                      style: context.small,
                    ),
                  ],
                )
              : uploading
              ? const Center(child: CircularProgressIndicator())
              : Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Change',
                      style: context.small.copyWith(color: colors.white),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
