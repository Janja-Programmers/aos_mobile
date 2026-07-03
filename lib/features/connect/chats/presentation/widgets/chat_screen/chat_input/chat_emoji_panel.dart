import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';

class ChatEmojiPanel extends StatefulWidget {
  const ChatEmojiPanel({
    super.key,
    required this.onEmojiSelected,
    required this.onClose,
  });

  final ValueChanged<String> onEmojiSelected;
  final VoidCallback onClose;

  @override
  State<ChatEmojiPanel> createState() => _ChatEmojiPanelState();
}

class _ChatEmojiPanelState extends State<ChatEmojiPanel> {
  final TextEditingController _searchController = TextEditingController();

  int _selectedCategory = 0;

  static const List<_EmojiCategory> _categories = [
    _EmojiCategory(
      icon: Icons.access_time_rounded,
      label: 'Recent',
      emojis: ['😀', '😃', '😄', '😁', '😆', '🤣', '😂', '🙂'],
    ),
    _EmojiCategory(
      icon: Icons.emoji_emotions_rounded,
      label: 'Smileys',
      emojis: [
        '😀',
        '😃',
        '😄',
        '😁',
        '😆',
        '😅',
        '😂',
        '🤣',
        '🙂',
        '🙃',
        '😉',
        '😊',
        '😇',
        '🥰',
        '😍',
        '🤩',
        '😘',
        '😗',
        '☺️',
        '😚',
        '😋',
        '😛',
        '😜',
        '🤪',
        '🤗',
        '🤭',
        '🤫',
        '🤔',
        '😐',
        '😑',
        '😶',
        '🙄',
        '😏',
        '😣',
        '😥',
        '😮',
        '🤐',
        '😯',
        '😪',
        '😫',
        '🥱',
        '😴',
        '😌',
        '😔',
        '😬',
        '🤥',
      ],
    ),
    _EmojiCategory(
      icon: Icons.pets_rounded,
      label: 'Animals',
      emojis: [
        '🐶',
        '🐱',
        '🐭',
        '🐹',
        '🐰',
        '🦊',
        '🐻',
        '🐼',
        '🐨',
        '🐯',
        '🦁',
        '🐮',
        '🐷',
        '🐸',
        '🐵',
        '🐔',
        '🐧',
        '🐦',
        '🐤',
        '🦆',
        '🦅',
        '🦉',
        '🦇',
        '🐺',
      ],
    ),
    _EmojiCategory(
      icon: Icons.fastfood_rounded,
      label: 'Food',
      emojis: [
        '🍏',
        '🍎',
        '🍐',
        '🍊',
        '🍋',
        '🍌',
        '🍉',
        '🍇',
        '🍓',
        '🫐',
        '🍈',
        '🍒',
        '🍑',
        '🥭',
        '🍍',
        '🥥',
        '🥝',
        '🍅',
        '🍆',
        '🥑',
        '🥦',
        '🥬',
        '🥒',
        '🌶️',
      ],
    ),
    _EmojiCategory(
      icon: Icons.flag_rounded,
      label: 'Flags',
      emojis: [
        '🇰🇪',
        '🇺🇬',
        '🇹🇿',
        '🇷🇼',
        '🇧🇮',
        '🇪🇹',
        '🇸🇴',
        '🇳🇬',
        '🇬🇭',
        '🇿🇦',
        '🇨🇩',
        '🇺🇸',
        '🇬🇧',
        '🇫🇷',
        '🇨🇳',
        '🇮🇳',
      ],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final query = _searchController.text.trim().toLowerCase();
    final emojis = _filteredEmojis(query);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: SizedBox(
        height: 286,
        child: Column(
          children: [
            SizedBox(
              height: 48,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final selected = index == _selectedCategory;
                  return IconButton(
                    onPressed: () {
                      setState(() => _selectedCategory = index);
                    },
                    icon: Icon(
                      category.icon,
                      color: selected ? colors.primary : colors.textMuted,
                    ),
                    tooltip: category.label,
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(width: 2),
                itemCount: _categories.length,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search emoji',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: query.isEmpty
                      ? IconButton(
                          onPressed: widget.onClose,
                          icon: const Icon(Icons.close_rounded),
                        )
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.backspace_outlined),
                        ),
                  filled: true,
                  fillColor: colors.elevated,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: colors.primary),
                  ),
                ),
              ),
            ),
            Expanded(
              child: emojis.isEmpty
                  ? Center(child: Text('No emoji found', style: context.pMuted))
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 8,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 8,
                          ),
                      itemCount: emojis.length,
                      itemBuilder: (context, index) {
                        final emoji = emojis[index];
                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => widget.onEmojiSelected(emoji),
                          child: Center(
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 30),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _filteredEmojis(String query) {
    if (query.isEmpty) return _categories[_selectedCategory].emojis;

    final all = _categories
        .expand((category) => category.emojis)
        .toSet()
        .toList(growable: false);

    final matches = <String>[];
    for (final emoji in all) {
      final label = _emojiLabels[emoji] ?? '';
      if (label.contains(query)) matches.add(emoji);
    }
    return matches;
  }
}

class _EmojiCategory {
  const _EmojiCategory({
    required this.icon,
    required this.label,
    required this.emojis,
  });

  final IconData icon;
  final String label;
  final List<String> emojis;
}

const _emojiLabels = <String, String>{
  '😀': 'grin happy smile',
  '😃': 'smile happy',
  '😄': 'smile laugh',
  '😁': 'grin teeth',
  '😆': 'laugh squint',
  '😅': 'sweat smile',
  '😂': 'tears laugh',
  '🤣': 'rolling laugh',
  '🙂': 'smile',
  '😉': 'wink',
  '😊': 'blush smile',
  '🥰': 'love hearts',
  '😍': 'love eyes',
  '🤩': 'star eyes',
  '😘': 'kiss',
  '😋': 'yum tongue',
  '😛': 'tongue',
  '😜': 'wink tongue',
  '🤗': 'hug',
  '🤔': 'think',
  '😴': 'sleep',
  '😬': 'grimace',
  '🐶': 'dog pet',
  '🐱': 'cat pet',
  '🍎': 'apple fruit',
  '🍌': 'banana fruit',
  '🍉': 'watermelon fruit',
  '🇰🇪': 'kenya flag',
};
