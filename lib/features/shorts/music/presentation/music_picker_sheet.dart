import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/shorts/music/domain/short_sound.dart';

Future<ShortSound?> showMusicPickerSheet(BuildContext context) {
  return showModalBottomSheet<ShortSound>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const MusicPickerSheet(),
  );
}

class MusicPickerSheet extends StatefulWidget {
  const MusicPickerSheet({super.key});

  @override
  State<MusicPickerSheet> createState() => _MusicPickerSheetState();
}

class _MusicPickerSheetState extends State<MusicPickerSheet> {
  final _queryController = TextEditingController();
  String _query = '';

  static const _sounds = <ShortSound>[
    ShortSound.original,
    ShortSound(
      id: 'coming_soon_trending',
      title: 'Trending sounds',
      artist: 'Coming soon',
      durationSeconds: 15,
      usageCount: 0,
    ),
    ShortSound(
      id: 'coming_soon_favorites',
      title: 'Favorite sounds',
      artist: 'Coming soon',
      durationSeconds: 20,
      usageCount: 0,
    ),
  ];

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final filtered = _sounds
        .where((sound) {
          final q = _query.trim().toLowerCase();
          if (q.isEmpty) return true;
          return sound.title.toLowerCase().contains(q) ||
              sound.artist.toLowerCase().contains(q);
        })
        .toList(growable: false);

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * .76,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text('Add music', style: context.h5)),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  Text(
                    'Music is UI-ready. Backend endpoints can be wired here later without changing the posting flow.',
                    style: context.small.copyWith(color: colors.textMuted),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _queryController,
                    onChanged: (value) => setState(() => _query = value),
                    decoration: InputDecoration(
                      hintText: 'Search sounds...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: filtered.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, index) {
                  final sound = filtered[index];
                  final isOriginal = sound.id == ShortSound.original.id;

                  return InkWell(
                    onTap: () => Navigator.pop(context, sound),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colors.border),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: colors.primary.withOpacity(.10),
                            child: Icon(
                              isOriginal
                                  ? Icons.graphic_eq_rounded
                                  : Icons.music_note_rounded,
                              color: colors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(sound.title, style: context.pStrong),
                                const SizedBox(height: 2),
                                Text(
                                  sound.artist,
                                  style: context.small.copyWith(
                                    color: colors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isOriginal)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colors.primary.withOpacity(.08),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Soon',
                                style: context.small.copyWith(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          else
                            Icon(Icons.check_rounded, color: colors.primary),
                        ],
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
}
