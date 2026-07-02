import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/connect/conversations/presentation/widgets/connect_story_template_strip.dart';

class StoryTemplateViewerScreen extends StatefulWidget {
  const StoryTemplateViewerScreen({super.key, required this.storyId});

  final String storyId;

  @override
  State<StoryTemplateViewerScreen> createState() =>
      _StoryTemplateViewerScreenState();
}

class _StoryTemplateViewerScreenState extends State<StoryTemplateViewerScreen> {
  final _commentController = TextEditingController();
  bool _liked = false;
  bool _showMenu = false;

  ConnectStoryTemplateItem get _story {
    return connectStoryTemplateItems.firstWhere(
      (item) => item.id == widget.storyId,
      orElse: () => connectStoryTemplateItems.first,
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _toggleLike() {
    HapticFeedback.selectionClick();
    setState(() => _liked = !_liked);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final story = _story;
    final keyboardBottom = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: _StoryGradient(story: story)),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),
                const _ProgressBars(),
                const SizedBox(height: 28),
                _StoryTopBar(
                  story: story,
                  onMenuTap: () => setState(() => _showMenu = !_showMenu),
                  onClose: () => Navigator.of(context).maybePop(),
                ),
                const Spacer(),
                AnimatedPadding(
                  duration: const Duration(milliseconds: 180),
                  padding: EdgeInsets.only(bottom: keyboardBottom),
                  child: _StoryComposer(
                    controller: _commentController,
                    liked: _liked,
                    onLike: _toggleLike,
                  ),
                ),
              ],
            ),
          ),
          if (_showMenu)
            Positioned(
              right: 24,
              top: MediaQuery.paddingOf(context).top + 92,
              child: _StoryActionMenu(
                onDismiss: () => setState(() => _showMenu = false),
              ),
            ),
        ],
      ),
    );
  }
}

class _StoryGradient extends StatelessWidget {
  const _StoryGradient({required this.story});

  final ConnectStoryTemplateItem story;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE95EA8), Color(0xFF8D6BFF)],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Text(
            story.id == 'eleanor-template-story'
                ? 'Good morning! ☀️'
                : 'Welcome to AOS stories ✨',
            textAlign: TextAlign.center,
            style: context.h3.copyWith(
              color: colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              shadows: [
                Shadow(
                  color: colors.black.withValues(alpha: 0.22),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressBars extends StatelessWidget {
  const _ProgressBars();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(2, (index) {
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index == 0 ? 8 : 0),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: index == 0 ? 0.96 : 0.42),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _StoryTopBar extends StatelessWidget {
  const _StoryTopBar({
    required this.story,
    required this.onMenuTap,
    required this.onClose,
  });

  final ConnectStoryTemplateItem story;
  final VoidCallback onMenuTap;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: colors.white.withValues(alpha: 0.25),
            child: Text(
              story.initial,
              style: context.h5.copyWith(
                color: colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  story.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.h5.copyWith(
                    color: colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '2h ago',
                  style: context.p.copyWith(
                    color: colors.white.withValues(alpha: 0.82),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onMenuTap,
            icon: Icon(Icons.more_horiz_rounded, color: colors.white, size: 34),
          ),
          IconButton(
            onPressed: onClose,
            icon: Icon(Icons.close_rounded, color: colors.white, size: 38),
          ),
        ],
      ),
    );
  }
}

class _StoryActionMenu extends StatelessWidget {
  const _StoryActionMenu({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 224,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: colors.elevated,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: colors.black.withValues(alpha: 0.24),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StoryMenuItem(
              icon: Icons.volume_off_rounded,
              label: 'Mute',
              color: colors.textPrimary,
              onTap: onDismiss,
            ),
            const SizedBox(height: 14),
            _StoryMenuItem(
              icon: Icons.info_outline_rounded,
              label: 'Report',
              color: colors.error,
              onTap: onDismiss,
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryMenuItem extends StatelessWidget {
  const _StoryMenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(width: 22),
            Text(
              label,
              style: context.h5.copyWith(color: color, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryComposer extends StatelessWidget {
  const _StoryComposer({
    required this.controller,
    required this.liked,
    required this.onLike,
  });

  final TextEditingController controller;
  final bool liked;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 22, 28, 22),
      color: colors.black.withValues(alpha: 0.88),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 66,
              padding: const EdgeInsets.symmetric(horizontal: 22),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF4F7),
                borderRadius: BorderRadius.circular(34),
              ),
              child: TextField(
                controller: controller,
                style: context.p.copyWith(color: const Color(0xFF1B1B1B)),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Comment...',
                  hintStyle: context.p.copyWith(
                    color: const Color(0xFF8EA0AE),
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onLike,
            child: Icon(
              liked ? Icons.favorite_rounded : Icons.favorite_rounded,
              color: liked ? colors.primary : const Color(0xFF7B90AA),
              size: 44,
            ),
          ),
        ],
      ),
    );
  }
}
