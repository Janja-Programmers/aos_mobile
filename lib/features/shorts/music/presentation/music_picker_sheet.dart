import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/shorts/music/data/shorts_sounds_api.dart';
import 'package:africaonlinestores/features/shorts/music/domain/short_sound.dart';
import 'package:africaonlinestores/features/shorts/shared/application/providers/shorts_providers.dart';

Future<ShortSound?> showMusicPickerSheet(
  BuildContext context, {
  bool commercialSafeOnly = false,
}) {
  return showModalBottomSheet<ShortSound>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => MusicPickerSheet(commercialSafeOnly: commercialSafeOnly),
  );
}

class MusicPickerSheet extends ConsumerStatefulWidget {
  final bool commercialSafeOnly;

  const MusicPickerSheet({super.key, this.commercialSafeOnly = false});

  @override
  ConsumerState<MusicPickerSheet> createState() => _MusicPickerSheetState();
}

class _MusicPickerSheetState extends ConsumerState<MusicPickerSheet> {
  final _queryController = TextEditingController();
  final _scrollController = ScrollController();
  final _player = AudioPlayer();

  final List<ShortSound> _sounds = [ShortSound.original];
  String? _nextCursor;
  String? _playingSoundId;
  Timer? _debounce;
  String _query = '';
  String _sourceType = 'all';
  bool _showFavorites = false;
  bool _loading = false;
  bool _loadingMore = false;
  bool _uploading = false;
  bool _hasMore = false;
  String? _error;

  ShortsSoundsApi get _api => ref.read(shortsSoundsApiProvider);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitial());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _queryController.dispose();
    _scrollController.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    setState(() {
      _loading = true;
      _error = null;
      _nextCursor = null;
      _hasMore = false;
      _sounds
        ..clear()
        ..add(ShortSound.original);
    });

    final res = _showFavorites
        ? await _api.myFavoriteSounds(limit: 20)
        : await _api.listSounds(limit: 20, sourceType: _sourceType);

    if (!mounted) return;

    res.fold(
      (failure) {
        setState(() {
          _error = failure.message;
          _loading = false;
        });
      },
      (page) {
        setState(() {
          _sounds.addAll(_filterCommercial(page.items));
          _nextCursor = page.nextCursor;
          _hasMore = page.hasMore;
          _loading = false;
        });
      },
    );
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore || _nextCursor == null || _query.isNotEmpty) {
      return;
    }

    setState(() => _loadingMore = true);
    final res = _showFavorites
        ? await _api.myFavoriteSounds(limit: 20, cursor: _nextCursor)
        : await _api.listSounds(
            limit: 20,
            cursor: _nextCursor,
            sourceType: _sourceType,
          );

    if (!mounted) return;

    res.fold(
      (failure) => setState(() {
        _error = failure.message;
        _loadingMore = false;
      }),
      (page) => setState(() {
        _mergeSounds(_filterCommercial(page.items));
        _nextCursor = page.nextCursor;
        _hasMore = page.hasMore;
        _loadingMore = false;
      }),
    );
  }

  Future<void> _search(String value) async {
    _debounce?.cancel();
    _query = value.trim();

    _debounce = Timer(const Duration(milliseconds: 350), () async {
      if (!mounted) return;
      if (_query.isEmpty) {
        await _loadInitial();
        return;
      }

      setState(() {
        _loading = true;
        _error = null;
        _nextCursor = null;
        _hasMore = false;
        _sounds
          ..clear()
          ..add(ShortSound.original);
      });

      final res = await _api.searchSounds(query: _query, limit: 30);
      if (!mounted) return;

      res.fold(
        (failure) => setState(() {
          _error = failure.message;
          _loading = false;
        }),
        (items) => setState(() {
          _sounds.addAll(_filterCommercial(items));
          _loading = false;
        }),
      );
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      _loadMore();
    }
  }

  List<ShortSound> _filterCommercial(List<ShortSound> items) {
    if (!widget.commercialSafeOnly) return items;
    return items
        .where((sound) => sound.isCommercialSafe)
        .toList(growable: false);
  }

  void _mergeSounds(List<ShortSound> items) {
    final existing = _sounds.map((sound) => sound.id).toSet();
    for (final sound in items) {
      if (existing.add(sound.id)) _sounds.add(sound);
    }
  }

  Future<void> _toggleFavorite(ShortSound sound) async {
    if (sound.isOriginal) return;

    final previous = sound;
    final optimistic = sound.copyWith(
      isFavorite: !sound.isFavorite,
      favoriteCount: sound.isFavorite
          ? (sound.favoriteCount - 1).clamp(0, 1 << 31).toInt()
          : sound.favoriteCount + 1,
    );
    _replaceSound(optimistic);

    final res = await _api.favoriteSound(soundId: sound.id);
    if (!mounted) return;

    res.fold(
      (failure) {
        _replaceSound(previous);
        _showSnack(failure.message);
      },
      (result) {
        _replaceSound(
          optimistic.copyWith(
            isFavorite: result.favorited,
            favoriteCount: result.favoriteCount,
            favoriteCountDisplay: result.favoriteCountDisplay,
          ),
        );
      },
    );
  }

  void _replaceSound(ShortSound sound) {
    final index = _sounds.indexWhere((item) => item.id == sound.id);
    if (index == -1) return;
    setState(() => _sounds[index] = sound);
  }

  Future<void> _togglePreview(ShortSound sound) async {
    if (!sound.isPlayable) return;

    try {
      if (_playingSoundId == sound.id) {
        await _player.stop();
        if (mounted) setState(() => _playingSoundId = null);
        return;
      }

      await _player.setUrl(sound.fileUrl!);
      await _player.play();
      if (mounted) setState(() => _playingSoundId = sound.id);
    } catch (_) {
      if (mounted) _showSnack('Could not preview this sound.');
    }
  }

  Future<void> _uploadSound() async {
    final picked = await FilePicker.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );
    final path = picked?.files.single.path;
    if (path == null || path.trim().isEmpty) return;

    final file = File(path);
    final filename = picked!.files.single.name;
    final titleController = TextEditingController(
      text: filename.contains('.') ? filename.split('.').first : filename,
    );
    final artistController = TextEditingController(text: 'Original sound');
    bool isCommercialSafe = false;

    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Upload sound'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    TextField(
                      controller: artistController,
                      decoration: const InputDecoration(labelText: 'Artist'),
                    ),
                    CheckboxListTile.adaptive(
                      value: isCommercialSafe,
                      onChanged: (value) => setDialogState(
                        () => isCommercialSafe = value ?? false,
                      ),
                      title: const Text('Commercial safe'),
                      subtitle: const Text(
                        'Use only if you own or have rights to this audio.',
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text(
                    'Upload',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    final title = titleController.text.trim();
    final artist = artistController.text.trim();
    titleController.dispose();
    artistController.dispose();

    if (confirmed != true || title.isEmpty) return;

    setState(() => _uploading = true);

    Duration? duration;
    final probe = AudioPlayer();
    try {
      duration = await probe.setFilePath(file.path);
    } catch (_) {
      duration = null;
    } finally {
      await probe.dispose();
    }

    final init = await _api.initSoundUpload(
      filename: filename,
      sizeBytes: await file.length(),
    );

    final uploadReady = await init.fold<Future<ShortSound?>>(
      (failure) async {
        _showSnack(failure.message);
        return null;
      },
      (result) async {
        try {
          await Dio().put(
            result.uploadUrl,
            data: file.openRead(),
            options: Options(
              headers: {
                'Content-Length': await file.length(),
                ...result.uploadHeaders,
              },
            ),
          );
        } catch (_) {
          _showSnack('Failed to upload sound file.');
          return null;
        }

        final confirmedSound = await _api.confirmSoundUpload(
          fileKey: result.fileKey,
          title: title,
          artist: artist,
          sourceType: 'uploaded',
          durationSeconds: duration?.inMilliseconds == null
              ? 0
              : duration!.inMilliseconds / 1000,
          isCommercialSafe: isCommercialSafe,
        );

        return confirmedSound.fold((failure) {
          _showSnack(failure.message);
          return null;
        }, (sound) => sound);
      },
    );

    if (!mounted) return;

    setState(() => _uploading = false);

    if (uploadReady != null) {
      setState(() {
        _sounds.insert(1, uploadReady);
      });

      if (widget.commercialSafeOnly && !uploadReady.isCommercialSafe) {
        _showSnack(
          'Sound uploaded, but shop shorts can only use commercial-safe sounds.',
        );
        return;
      }

      _showSnack('Sound uploaded.');
      Navigator.pop(context, uploadReady);
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * .82,
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
                      if (_uploading)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        IconButton(
                          tooltip: 'Upload sound',
                          onPressed: _uploadSound,
                          icon: const Icon(Icons.upload_file_rounded),
                        ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  Text(
                    widget.commercialSafeOnly
                        ? 'Shop shorts can only use commercial-safe sounds.'
                        : 'Choose a sound, use original video audio, or upload your own audio.',
                    style: context.small.copyWith(color: colors.textMuted),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _queryController,
                    onChanged: _search,
                    decoration: InputDecoration(
                      hintText: 'Search sounds...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _filterChip(
                          'All',
                          selected: !_showFavorites && _sourceType == 'all',
                          onTap: () {
                            _showFavorites = false;
                            _sourceType = 'all';
                            _loadInitial();
                          },
                        ),
                        _filterChip(
                          'Library',
                          selected: !_showFavorites && _sourceType == 'library',
                          onTap: () {
                            _showFavorites = false;
                            _sourceType = 'library';
                            _loadInitial();
                          },
                        ),
                        _filterChip(
                          'Commercial',
                          selected:
                              !_showFavorites && _sourceType == 'commercial',
                          onTap: () {
                            _showFavorites = false;
                            _sourceType = 'commercial';
                            _loadInitial();
                          },
                        ),
                        _filterChip(
                          'Uploaded',
                          selected:
                              !_showFavorites && _sourceType == 'uploaded',
                          onTap: () {
                            _showFavorites = false;
                            _sourceType = 'uploaded';
                            _loadInitial();
                          },
                        ),
                        _filterChip(
                          'Favorites',
                          selected: _showFavorites,
                          onTap: () {
                            _showFavorites = true;
                            _queryController.clear();
                            _query = '';
                            _loadInitial();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _body(colors)),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(
    String label, {
    required bool selected,
    required VoidCallback onTap,
  }) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: colors.primary.withOpacity(.14),
        side: BorderSide(color: selected ? colors.primary : colors.border),
      ),
    );
  }

  Widget _body(dynamic colors) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(onPressed: _loadInitial, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (_sounds.length == 1 && widget.commercialSafeOnly) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No commercial-safe sounds found. Use original audio or upload a sound you have rights to use.',
            textAlign: TextAlign.center,
            style: context.p.copyWith(color: colors.textMuted),
          ),
        ),
      );
    }

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: _sounds.length + (_loadingMore ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, index) {
        if (index >= _sounds.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }
        return _SoundTile(
          sound: _sounds[index],
          isPlaying: _playingSoundId == _sounds[index].id,
          onPick: () => Navigator.pop(context, _sounds[index]),
          onPreview: () => _togglePreview(_sounds[index]),
          onFavorite: () => _toggleFavorite(_sounds[index]),
        );
      },
    );
  }
}

class _SoundTile extends StatelessWidget {
  final ShortSound sound;
  final bool isPlaying;
  final VoidCallback onPick;
  final VoidCallback onPreview;
  final VoidCallback onFavorite;

  const _SoundTile({
    required this.sound,
    required this.isPlaying,
    required this.onPick,
    required this.onPreview,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isOriginal = sound.isOriginal;

    return InkWell(
      onTap: onPick,
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          sound.title,
                          style: context.pStrong,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (sound.isCommercialSafe && !isOriginal)
                        Icon(
                          Icons.verified_rounded,
                          size: 16,
                          color: colors.success,
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isOriginal
                        ? 'Original video audio'
                        : [
                            if (sound.artist.trim().isNotEmpty) sound.artist,
                            if (sound.durationLabel.isNotEmpty)
                              sound.durationLabel,
                            '${sound.usageCountDisplay} uses',
                          ].join(' • '),
                    style: context.small.copyWith(color: colors.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (!isOriginal)
              IconButton(
                tooltip: isPlaying ? 'Stop preview' : 'Preview',
                onPressed: onPreview,
                icon: Icon(
                  isPlaying
                      ? Icons.stop_circle_rounded
                      : Icons.play_circle_rounded,
                ),
              ),
            if (!isOriginal)
              IconButton(
                tooltip: sound.isFavorite ? 'Unfavorite' : 'Favorite',
                onPressed: onFavorite,
                icon: Icon(
                  sound.isFavorite
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                ),
              )
            else
              Icon(Icons.check_rounded, color: colors.primary),
          ],
        ),
      ),
    );
  }
}
