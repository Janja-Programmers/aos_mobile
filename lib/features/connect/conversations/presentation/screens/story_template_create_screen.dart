import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

class StoryTemplateCreateScreen extends StatelessWidget {
  const StoryTemplateCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: const Color(0xFF0E151B),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 24, 30, 26),
              child: Row(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Icon(Icons.close_rounded, color: colors.white, size: 36),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    'Add story',
                    style: context.h4.copyWith(
                      color: colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                children: [
                  Expanded(
                    child: _StoryToolCard(icon: Icons.videocam_rounded, label: 'Video'),
                  ),
                  SizedBox(width: 24),
                  Expanded(
                    child: _StoryToolCard(icon: Icons.grid_view_rounded, label: 'Layout'),
                  ),
                  SizedBox(width: 24),
                  Expanded(
                    child: _StoryToolCard(icon: Icons.mic_rounded, label: 'Voice'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 34),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                children: [
                  Text(
                    'Recents',
                    style: context.h5.copyWith(
                      color: colors.white.withValues(alpha: 0.78),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.arrow_drop_down_rounded, color: colors.white.withValues(alpha: 0.78)),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                _RecentCameraTile(
                  onTap: () => context.pushNamed(AppRoutes.nConnectStoryConfirm),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => context.pushNamed(AppRoutes.nConnectStoryConfirm),
                  child: const _RecentTemplateTile(),
                ),
              ],
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 38, 40),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => context.pushNamed(AppRoutes.nConnectStoryConfirm),
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C2632),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(Icons.folder_outlined, color: colors.white, size: 34),
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

class _StoryToolCard extends StatelessWidget {
  const _StoryToolCard({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      height: 118,
      decoration: BoxDecoration(
        color: const Color(0xFF1B2531),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF334150)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: colors.white, size: 34),
          const SizedBox(height: 16),
          Text(
            label,
            style: context.h5.copyWith(
              color: colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentCameraTile extends StatelessWidget {
  const _RecentCameraTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 148,
        height: 148,
        color: const Color(0xFF1A2430),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, color: colors.white, size: 42),
            const SizedBox(height: 14),
            Text(
              'Camera',
              style: context.h5.copyWith(
                color: colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentTemplateTile extends StatelessWidget {
  const _RecentTemplateTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      height: 148,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFD41D), Color(0xFFFFB700)],
        ),
      ),
      child: Center(
        child: Text(
          '100%\naccuracy!',
          textAlign: TextAlign.center,
          style: context.h5.copyWith(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
