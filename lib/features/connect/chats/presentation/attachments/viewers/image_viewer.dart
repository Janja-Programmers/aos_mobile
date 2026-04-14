import 'package:flutter/material.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

class ImageViewer extends StatelessWidget {
  final String url;

  const ImageViewer({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.black,
      appBar: AppBar(
        backgroundColor: colors.black,
        iconTheme: IconThemeData(color: colors.surface),
      ),
      body: InteractiveViewer(
        minScale: 1,
        maxScale: 4,
        clipBehavior: Clip.none,
        child: Center(
          child: Image.network(
            url,
            fit: BoxFit.contain,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
        ),
      ),
    );
  }
}
