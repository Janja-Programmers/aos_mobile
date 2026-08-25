import 'dart:async';

import 'package:africaonlinestores/core/media/application/media_services_provider.dart';
import 'package:africaonlinestores/core/media/domain/media_policy.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/providers/short_creation_providers.dart';
import 'package:africaonlinestores/features/shorts/music/application/sound_picker_controller.dart';
import 'package:africaonlinestores/features/shorts/music/domain/short_sound.dart';
import 'package:africaonlinestores/features/shorts/shared/application/providers/shorts_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

Future<ShortSound?> showMusicPickerSheet(
  BuildContext context, {
  bool commercialSafeOnly = false,
}) {
  return showModalBottomSheet<ShortSound>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => MusicPickerSheet(commercialSafeOnly: commercialSafeOnly),
  );
}

class MusicPickerSheet extends ConsumerStatefulWidget {
  const MusicPickerSheet({super.key, this.commercialSafeOnly = false});

  final bool commercialSafeOnly;

  @override
  ConsumerState<MusicPickerSheet> createState() => _MusicPickerSheetState();
}

class _MusicPickerSheetState extends ConsumerState<MusicPickerSheet> {
  final TextEditingController _query = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _uploading = false;

  SoundPickerController get _controller =>
      ref.read(soundPickerControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        _controller.initialize(commercialSafeOnly: widget.commercialSafeOnly),
      );
    });
  }

  @override
  void dispose() {
    _query.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    if (_scroll.position.extentAfter < 280) {
      unawaited(
        _controller.loadMore(commercialSafeOnly: widget.commercialSafeOnly),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(soundPickerControllerProvider);
    final theme = Theme.of(context);
    final height = MediaQuery.sizeOf(context).height * .9;

    ref.listen<SoundPickerState>(soundPickerControllerProvider, (
      previous,
      next,
    ) {
      final error = next.errorMessage;
      if (error != null && error != previous?.errorMessage) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
    });

    return SizedBox(
      height: height,
      child: Column(
        children: <Widget>[
          const SizedBox(height: 8),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _query,
                    onChanged: (value) => _controller.search(
                      value,
                      commercialSafeOnly: widget.commercialSafeOnly,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Search sounds',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton.tonalIcon(
                  onPressed: _uploading ? null : _uploadSound,
                  icon: _uploading
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.library_music_outlined),
                  label: const Text('Import'),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: <Widget>[
                _chip(
                  'For you',
                  !state.showFavorites && state.sourceType == 'all',
                  () {
                    _controller.setSourceType(
                      'all',
                      commercialSafeOnly: widget.commercialSafeOnly,
                    );
                  },
                ),
                _chip(
                  'Library',
                  !state.showFavorites && state.sourceType == 'library',
                  () {
                    _controller.setSourceType(
                      'library',
                      commercialSafeOnly: widget.commercialSafeOnly,
                    );
                  },
                ),
                _chip(
                  'Commercial',
                  !state.showFavorites && state.sourceType == 'commercial',
                  () {
                    _controller.setSourceType(
                      'commercial',
                      commercialSafeOnly: widget.commercialSafeOnly,
                    );
                  },
                ),
                _chip('Saved', state.showFavorites, () {
                  _controller.setFavorites(
                    true,
                    commercialSafeOnly: widget.commercialSafeOnly,
                  );
                }),
              ],
            ),
          ),
          Expanded(child: _body(state)),
        ],
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }

  Widget _body(SoundPickerState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.music_off_outlined, size: 48),
              const SizedBox(height: 12),
              const Text('No sounds found.'),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => _controller.retry(
                  commercialSafeOnly: widget.commercialSafeOnly,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        if (index == state.items.length) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final sound = state.items[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
          leading: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: <Color>[
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.tertiary,
                ],
              ),
            ),
            child: const Icon(Icons.music_note_rounded, color: Colors.white),
          ),
          title: Text(
            sound.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            sound.isOriginal
                ? 'Use the video audio'
                : <String>[
                    if (sound.artist.trim().isNotEmpty) sound.artist,
                    if (sound.usageCountDisplay.isNotEmpty)
                      '${sound.usageCountDisplay} shorts',
                    if (sound.durationLabel.isNotEmpty) sound.durationLabel,
                  ].join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => Navigator.of(context).pop(sound),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (sound.isPlayable)
                IconButton(
                  tooltip: state.playingSoundId == sound.id
                      ? 'Stop preview'
                      : 'Preview sound',
                  onPressed: () => _controller.togglePreview(sound),
                  icon: Icon(
                    state.playingSoundId == sound.id
                        ? Icons.stop_circle_outlined
                        : Icons.play_circle_outline,
                  ),
                ),
              if (!sound.isOriginal && sound.canFavorite)
                IconButton(
                  tooltip: sound.isFavorite
                      ? 'Remove from saved'
                      : 'Save sound',
                  onPressed: () => _controller.toggleFavorite(sound),
                  icon: Icon(
                    sound.isFavorite
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadSound() async {
    final picked = await ref
        .read(mediaAcquisitionServiceProvider)
        .pickAudio(useCase: MediaUseCase.soundUpload);
    if (picked == null) return;
    if (!mounted) {
      await picked.discard();
      return;
    }
    final details = await _askUploadDetails(picked.originalName);
    if (details == null || !mounted) {
      await picked.discard();
      return;
    }

    setState(() => _uploading = true);
    try {
      Duration? duration;
      final probe = AudioPlayer();
      try {
        duration = await probe.setFilePath(picked.path);
      } finally {
        await probe.dispose();
      }
      final upload = await ref
          .read(mediaUploadCoordinatorProvider)
          .upload(
            media: picked,
            useCase: MediaUseCase.soundUpload,
            discardSourceWhenDone: true,
          );
      final media = upload.rightOrNull;
      if (media == null) {
        _showMessage(upload.leftOrNull?.message ?? 'Could not upload sound.');
        return;
      }
      final created = await ref
          .read(shortsSoundsApiProvider)
          .createSoundFromMedia(
            soundMedia: media.mediaId,
            title: details.$1,
            artist: details.$2,
            durationSeconds: (duration?.inMilliseconds ?? 0) / 1000,
          );
      final sound = created.rightOrNull;
      if (sound == null) {
        _showMessage(created.leftOrNull?.message ?? 'Could not create sound.');
        return;
      }
      if (widget.commercialSafeOnly && !sound.isCommercialSafe) {
        _showMessage('Shop shorts require a commercial-safe sound.');
        return;
      }
      if (mounted) Navigator.of(context).pop(sound);
    } finally {
      await picked.discard();
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<(String, String)?> _askUploadDetails(String filename) async {
    final title = TextEditingController(
      text: filename.contains('.')
          ? filename.substring(0, filename.lastIndexOf('.'))
          : filename,
    );
    final artist = TextEditingController(text: 'Original sound');
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import sound'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: title,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: artist,
                decoration: const InputDecoration(labelText: 'Artist'),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final clean = title.text.trim();
              if (clean.isEmpty) return;
              Navigator.pop(context, (clean, artist.text.trim()));
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
    title.dispose();
    artist.dispose();
    return result;
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
