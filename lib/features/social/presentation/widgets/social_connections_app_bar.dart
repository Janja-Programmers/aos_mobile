import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';

class SocialConnectionsAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onAddTap;

  const SocialConnectionsAppBar({
    super.key,
    required this.title,
    this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AppBar(
      backgroundColor: colors.surface,
      elevation: 0,
      leading: BackButton(color: colors.textPrimary),
      centerTitle: true,
      title: Text(
        title,
        style: context.h5.copyWith(
          color: colors.textPrimary,
          fontWeight: FontWeight.w800,
        ),
      ),
      actions: [
        IconButton(
          onPressed: onAddTap,
          icon: Icon(
            Icons.person_add_alt_1_outlined,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
