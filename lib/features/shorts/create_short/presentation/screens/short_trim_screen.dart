import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:africaonlinestores/shared/images/app_image_decode.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ShortTrimSelection {
  const ShortTrimSelection({required this.start, required this.end});

  final Duration start;
  final Duration end;
}

class ShortTrimScreen extends StatefulWidget {
  const ShortTrimScreen({
    super.key,
    required this.sourcePath,
    required this.duration,
    required this.initialStart,
    required this.initialEnd,
  });

  final String sourcePath;
  final Duration duration;
  final Duration initialStart;
  final Duration initialEnd;

  @override
  State<ShortTrimScreen> createState() => _ShortTrimScreenState();
}

class _ShortTrimScreenState extends State<ShortTrimScreen> {
  late RangeValues _range;
  late final VideoPlayerController _player;
  late final Future<List<Uint8List>> _thumbnails;
  bool _initialized = false;
  bool _loopSeekInProgress = false;
  String? _error;

  bool get _changed =>
      (_range.start * 1000).round() != widget.initialStart.inMilliseconds ||
      (_range.end * 1000).round() != widget.initialEnd.inMilliseconds;

  @override
  void initState() {
    super.initState();
    final maxSeconds = widget.duration.inMilliseconds / 1000;
    final safeMax = maxSeconds <= 0 ? .3 : maxSeconds;
    final start = (widget.initialStart.inMilliseconds / 1000)
        .clamp(0, (safeMax - .3).clamp(0, safeMax))
        .toDouble();
    final end = (widget.initialEnd.inMilliseconds / 1000)
        .clamp(start + .3, safeMax)
        .toDouble();
    _range = RangeValues(start, end);
    _player = VideoPlayerController.file(File(widget.sourcePath))
      ..addListener(_onPlayerTick);
    _thumbnails = _buildThumbnails();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      await _player.initialize();
      await _player.setLooping(false);
      await _player.seekTo(
        Duration(milliseconds: (_range.start * 1000).round()),
      );
      await _player.play();
      if (mounted) setState(() => _initialized = true);
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not preview this video.');
    }
  }

  void _onPlayerTick() {
    if (!_initialized || !_player.value.isPlaying) return;
    final position = _player.value.position;
    final start = Duration(milliseconds: (_range.start * 1000).round());
    final end = Duration(milliseconds: (_range.end * 1000).round());
    if ((position < start || position >= end) && !_loopSeekInProgress) {
      _loopSeekInProgress = true;
      unawaited(
        _player.seekTo(start).whenComplete(() {
          _loopSeekInProgress = false;
        }),
      );
    }
  }

  @override
  void dispose() {
    _player.removeListener(_onPlayerTick);
    unawaited(_player.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rawMaxSeconds = widget.duration.inMilliseconds / 1000;
    final maxSeconds = rawMaxSeconds < .3 ? .3 : rawMaxSeconds;
    return PopScope(
      canPop: !_changed,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) await _confirmDiscard();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          leadingWidth: 94,
          leading: TextButton(
            onPressed: _onCancel,
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: _save,
              child: Text(
                'Save',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: Center(
                  child: _error != null
                      ? Text(
                          _error!,
                          style: const TextStyle(color: Colors.white),
                        )
                      : !_initialized
                      ? const CircularProgressIndicator()
                      : AspectRatio(
                          aspectRatio: _player.value.aspectRatio,
                          child: GestureDetector(
                            onTap: () async {
                              if (_player.value.isPlaying) {
                                await _player.pause();
                              } else {
                                await _player.play();
                              }
                              if (mounted) setState(() {});
                            },
                            child: VideoPlayer(_player),
                          ),
                        ),
                ),
              ),
              Container(
                color: const Color(0xFF111217),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * .38,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 74,
                        child: FutureBuilder<List<Uint8List>>(
                          future: _thumbnails,
                          builder: (context, snapshot) {
                            final AppImageDecodeSize decodeSize =
                                AppImageDecode.forBox(
                                  context,
                                  logicalHeight: 74,
                                );
                            if (snapshot.hasError) {
                              return const Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  color: Colors.white70,
                                ),
                              );
                            }
                            final items = snapshot.data ?? const <Uint8List>[];
                            if (items.isEmpty &&
                                snapshot.connectionState !=
                                    ConnectionState.done) {
                              return const Center(
                                child: LinearProgressIndicator(),
                              );
                            }
                            if (items.isEmpty) {
                              return const Center(
                                child: Text(
                                  'Preview frames unavailable',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              );
                            }
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Row(
                                children: items
                                    .map(
                                      (bytes) => Expanded(
                                        child: Image.memory(
                                          bytes,
                                          height: 74,
                                          fit: BoxFit.cover,
                                          cacheWidth: decodeSize.width,
                                          cacheHeight: decodeSize.height,
                                        ),
                                      ),
                                    )
                                    .toList(growable: false),
                              ),
                            );
                          },
                        ),
                      ),
                      Semantics(
                        label: 'Trim start and end handles',
                        value:
                            '${_format(_range.start)} to ${_format(_range.end)}',
                        child: RangeSlider(
                          max: maxSeconds,
                          values: _range,
                          onChanged: (value) {
                            final bounded = value.end - value.start < .3
                                ? RangeValues(value.start, value.start + .3)
                                : value;
                            final start = bounded.start
                                .clamp(
                                  0,
                                  (maxSeconds - .3).clamp(0, maxSeconds),
                                )
                                .toDouble();
                            final end = bounded.end
                                .clamp(start + .3, maxSeconds)
                                .toDouble();
                            setState(() => _range = RangeValues(start, end));
                            unawaited(
                              _player.seekTo(
                                Duration(
                                  milliseconds: (_range.start * 1000).round(),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            '${_format(_range.end - _range.start)} selected',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            tooltip: _player.value.isPlaying
                                ? 'Pause preview'
                                : 'Play preview',
                            onPressed: _initialized
                                ? () async {
                                    if (_player.value.isPlaying) {
                                      await _player.pause();
                                    } else {
                                      await _player.seekTo(
                                        Duration(
                                          milliseconds: (_range.start * 1000)
                                              .round(),
                                        ),
                                      );
                                      await _player.play();
                                    }
                                    if (mounted) setState(() {});
                                  }
                                : null,
                            color: Colors.white,
                            icon: Icon(
                              _player.value.isPlaying
                                  ? Icons.pause_circle_outline
                                  : Icons.play_circle_outline,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<Uint8List>> _buildThumbnails() async {
    const count = 8;
    final durationMs = widget.duration.inMilliseconds;
    final results = <Uint8List>[];
    for (var index = 0; index < count; index++) {
      final bytes = await VideoThumbnail.thumbnailData(
        video: widget.sourcePath,
        imageFormat: ImageFormat.JPEG,
        quality: 55,
        maxHeight: 320,
        timeMs: durationMs <= 0
            ? 0
            : (durationMs * index / (count - 1)).round(),
      );
      if (bytes != null) results.add(bytes);
    }
    return results;
  }

  Future<void> _onCancel() async {
    if (!_changed) {
      if (mounted) Navigator.pop(context);
      return;
    }
    await _confirmDiscard();
  }

  Future<void> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard trim changes?'),
        content: const Text(
          'Your previously saved trim range will be restored.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if ((discard ?? false) && mounted) Navigator.pop(context);
  }

  void _save() {
    final start = Duration(milliseconds: (_range.start * 1000).round());
    final end = Duration(milliseconds: (_range.end * 1000).round());
    if (end <= start || end - start < const Duration(milliseconds: 300)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a longer video segment.')),
      );
      return;
    }
    Navigator.pop(context, ShortTrimSelection(start: start, end: end));
  }

  String _format(double seconds) {
    final duration = Duration(milliseconds: (seconds * 1000).round());
    final minutes = duration.inMinutes;
    final remainder = duration.inSeconds.remainder(60);
    final tenths = duration.inMilliseconds.remainder(1000) ~/ 100;
    return '$minutes:${remainder.toString().padLeft(2, '0')}.$tenths';
  }
}
