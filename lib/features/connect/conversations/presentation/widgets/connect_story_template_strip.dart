import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';

@immutable
class ConnectStoryTemplateItem {
  const ConnectStoryTemplateItem({
    required this.id,
    required this.displayName,
    required this.initial,
    required this.isViewed,
    required this.isMine,
  });

  final String id;
  final String displayName;
  final String initial;
  final bool isViewed;
  final bool isMine;
}

// Template-only story data. This is intentionally local UI scaffolding until
// the backend exposes story listing, create, update, viewer, and reaction APIs.
const List<ConnectStoryTemplateItem> connectStoryTemplateItems = [
  ConnectStoryTemplateItem(
    id: 'eleanor-template-story',
    displayName: 'Eleanor P.',
    initial: 'E',
    isViewed: false,
    isMine: false,
  ),
  ConnectStoryTemplateItem(
    id: 'dianne-template-story',
    displayName: 'Dianne R.',
    initial: 'D',
    isViewed: false,
    isMine: false,
  ),
  ConnectStoryTemplateItem(
    id: 'guy-template-story',
    displayName: 'Guy Hawkins',
    initial: 'G',
    isViewed: true,
    isMine: false,
  ),
  ConnectStoryTemplateItem(
    id: 'jacob-template-story',
    displayName: 'Jacob Jones',
    initial: 'J',
    isViewed: true,
    isMine: false,
  ),
];

class ConnectStoryTemplateStrip extends StatelessWidget {
  const ConnectStoryTemplateStrip({
    super.key,
    required this.onCreateStory,
    required this.onStoryTap,
  });

  final VoidCallback onCreateStory;
  final ValueChanged<ConnectStoryTemplateItem> onStoryTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: double.infinity,
      color: colors.surface,
      padding: const EdgeInsets.only(top: 12, bottom: 18),
      child: SizedBox(
        height: 112,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: connectStoryTemplateItems.length + 1,
          separatorBuilder: (_, _) => const SizedBox(width: 18),
          itemBuilder: (context, index) {
            if (index == 0) {
              return _MyStoryItem(onTap: onCreateStory);
            }

            final story = connectStoryTemplateItems[index - 1];
            return _StoryItem(story: story, onTap: () => onStoryTap(story));
          },
        ),
      ),
    );
  }
}

class _MyStoryItem extends StatelessWidget {
  const _MyStoryItem({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 76,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: colors.elevated,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.border, width: 1.2),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    size: 36,
                    color: colors.textMuted,
                  ),
                ),
                Positioned(
                  right: -1,
                  bottom: 0,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.surface, width: 3),
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      color: colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'My Story',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.p.copyWith(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryItem extends StatelessWidget {
  const _StoryItem({required this.story, required this.onTap});

  final ConnectStoryTemplateItem story;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final ringColor = story.isViewed ? colors.border : colors.primary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 84,
        child: Column(
          children: [
            Container(
              width: 74,
              height: 74,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ringColor, width: 3),
              ),
              child: CircleAvatar(
                backgroundColor: colors.primary.withValues(alpha: 0.18),
                child: Text(
                  story.initial,
                  style: context.h5.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              story.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.p.copyWith(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
