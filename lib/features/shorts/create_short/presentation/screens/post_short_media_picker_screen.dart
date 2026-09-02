import 'dart:async';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/auth/domain/auth_state.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/providers/short_creation_providers.dart';
import 'package:africaonlinestores/features/shorts/create_short/domain/short_creation_models.dart';
import 'package:africaonlinestores/features/shorts/create_short/domain/short_draft.dart';
import 'package:africaonlinestores/features/shorts/create_short/presentation/screens/short_editor_screen.dart';
import 'package:africaonlinestores/features/shorts/music/domain/short_sound.dart';
import 'package:africaonlinestores/features/shorts/music/presentation/music_picker_sheet.dart';
import 'package:africaonlinestores/features/shorts/shared/application/providers/shorts_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class PostShortMediaPickerScreen extends ConsumerStatefulWidget {
  const PostShortMediaPickerScreen({super.key, this.initialSound});

  final ShortSound? initialSound;

  @override
  ConsumerState<PostShortMediaPickerScreen> createState() =>
      _PostShortMediaPickerScreenState();
}

class _PostShortMediaPickerScreenState
    extends ConsumerState<PostShortMediaPickerScreen>
    with WidgetsBindingObserver {
  late ShortSound _selectedSound;
  String? _openedPath;
  bool _checkedDraft = false;

  @override
  void initState() {
    super.initState();
    _selectedSound = widget.initialSound ?? ShortSound.original;
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_initializeRecorder());
    });
  }

  Future<void> _initializeRecorder() async {
    await ref.read(shortRecorderControllerProvider.notifier).initialize();
    if (!mounted) return;
    final initialSound = widget.initialSound;
    if (initialSound == null || initialSound.isOriginal) {
      await _offerLatestDraft();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    unawaited(
      ref
          .read(shortRecorderControllerProvider.notifier)
          .onLifecycleChanged(state),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shortRecorderControllerProvider);
    final controller = ref.read(shortRecorderControllerProvider.notifier);

    ref.listen<ShortRecorderState>(shortRecorderControllerProvider, (
      previous,
      next,
    ) {
      final path = next.recordedPath;
      if (next.phase == ShortRecorderPhase.recorded &&
          path != null &&
          path != _openedPath) {
        _openedPath = path;
        unawaited(_openEditor(path));
      }
    });

    return PopScope(
      canPop: !state.isRecording && !state.isBusy,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && state.isRecording) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Stop recording before leaving.')),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              _preview(
                state,
                controller.cameraPreview,
                controller.cameraPreviewSize,
              ),
              _topBar(state),
              if (state.phase == ShortRecorderPhase.ready ||
                  state.phase == ShortRecorderPhase.recording)
                _rightActions(state),
              _bottomControls(state),
              if (state.isBusy)
                const ColoredBox(
                  color: Color(0x55000000),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _preview(
    ShortRecorderState state,
    Widget? cameraPreview,
    Size? previewSize,
  ) {
    if (state.phase == ShortRecorderPhase.permissionDenied ||
        state.phase == ShortRecorderPhase.unavailable ||
        state.phase == ShortRecorderPhase.error) {
      return _errorState(state);
    }
    if (cameraPreview == null || previewSize == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text('Preparing camera…', style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }
    return Center(
      child: ClipRect(
        child: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: previewSize.height,
              height: previewSize.width,
              child: cameraPreview,
            ),
          ),
        ),
      ),
    );
  }

  Widget _errorState(ShortRecorderState state) {
    final isPermission = state.phase == ShortRecorderPhase.permissionDenied;
    final controller = ref.read(shortRecorderControllerProvider.notifier);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              isPermission ? Icons.no_photography_outlined : Icons.videocam_off,
              color: Colors.white,
              size: 64,
            ),
            const SizedBox(height: 20),
            Text(
              state.errorMessage ?? 'The camera could not be opened.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 17),
            ),
            const SizedBox(height: 20),
            if (isPermission && state.microphoneEnabled) ...<Widget>[
              FilledButton.icon(
                onPressed: controller.toggleMicrophone,
                icon: const Icon(Icons.mic_off_outlined),
                label: Text(
                  'Record without microphone',
                  style: AppTextStylesX(context).button,
                ),
              ),
              const SizedBox(height: 8),
            ],
            FilledButton(
              onPressed: controller.initialize,
              child: Text('Retry', style: AppTextStylesX(context).button),
            ),
            if (isPermission)
              TextButton(
                onPressed: controller.openSettings,
                child: const Text('Open settings'),
              ),
            TextButton(
              onPressed: controller.importVideo,
              child: const Text('Upload a video instead'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar(ShortRecorderState state) {
    return Positioned(
      left: 12,
      right: 12,
      top: 8,
      child: Row(
        children: <Widget>[
          _darkCircleButton(
            tooltip: 'Close recorder',
            icon: Icons.close_rounded,
            onPressed: state.isRecording ? null : () => Navigator.pop(context),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FilledButton.tonalIcon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0x99000000),
                foregroundColor: Colors.white,
              ),
              onPressed: state.isRecording ? null : _pickSound,
              icon: const Icon(Icons.music_note_rounded),
              label: Text(
                _selectedSound.isOriginal ? 'Add sound' : _selectedSound.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStylesX(context).button,
              ),
            ),
          ),
          const SizedBox(width: 58),
        ],
      ),
    );
  }

  Widget _rightActions(ShortRecorderState state) {
    final controller = ref.read(shortRecorderControllerProvider.notifier);
    return Positioned(
      right: 10,
      top: 86,
      child: Column(
        children: <Widget>[
          _verticalAction(
            icon: Icons.cameraswitch_outlined,
            label: 'Flip',
            onPressed: state.isRecording || state.cameraCount < 2
                ? null
                : controller.flipCamera,
          ),
          _verticalAction(
            icon: state.flashEnabled ? Icons.flash_on : Icons.flash_off,
            label: 'Flash',
            onPressed: state.isRecording ? null : controller.toggleFlash,
          ),
          _verticalAction(
            icon: state.microphoneEnabled
                ? Icons.mic_none_rounded
                : Icons.mic_off_outlined,
            label: state.microphoneEnabled ? 'Mic' : 'Muted',
            onPressed: state.isRecording ? null : controller.toggleMicrophone,
          ),
        ],
      ),
    );
  }

  Widget _bottomControls(ShortRecorderState state) {
    final controller = ref.read(shortRecorderControllerProvider.notifier);
    final availableHeight = MediaQuery.sizeOf(context).height;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: availableHeight * .52),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (state.isRecording)
                Semantics(
                  liveRegion: true,
                  label: 'Recording time ${_durationText(state.elapsed)}',
                  child: Text(
                    _durationText(state.elapsed),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                children: ShortRecordingLimit.values
                    .map((limit) {
                      final selected = state.limit == limit;
                      return Semantics(
                        selected: selected,
                        button: true,
                        label: '${limit.label} recording duration',
                        child: TextButton(
                          onPressed: state.isRecording
                              ? null
                              : () => controller.setLimit(limit),
                          style: TextButton.styleFrom(
                            backgroundColor: selected
                                ? Colors.white
                                : Colors.black38,
                            foregroundColor: selected
                                ? Colors.black
                                : Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                          child: Text(limit.label),
                        ),
                      );
                    })
                    .toList(growable: false),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _bottomAction(
                    icon: Icons.auto_awesome,
                    label: 'Effects',
                    onPressed: null,
                  ),
                  Semantics(
                    button: true,
                    label: state.isRecording
                        ? 'Stop recording'
                        : 'Start recording',
                    value: state.isRecording
                        ? '${(state.progress * 100).round()} percent'
                        : null,
                    child: GestureDetector(
                      onTap: state.isBusy ? null : controller.toggleRecording,
                      child: CustomPaint(
                        painter: _RecordProgressPainter(
                          progress: state.progress,
                          recording: state.isRecording,
                        ),
                        child: SizedBox.square(
                          dimension: 96,
                          child: Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              width: state.isRecording ? 36 : 72,
                              height: state.isRecording ? 36 : 72,
                              decoration: BoxDecoration(
                                color: state.isRecording
                                    ? Colors.red
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(
                                  state.isRecording ? 8 : 99,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  _bottomAction(
                    icon: Icons.photo_library_outlined,
                    label: 'Upload',
                    onPressed: state.isRecording
                        ? null
                        : controller.importVideo,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _darkCircleButton({
    required String tooltip,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return IconButton.filled(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: const Color(0x99000000),
        foregroundColor: Colors.white,
      ),
      icon: Icon(icon),
    );
  }

  Widget _verticalAction({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: <Widget>[
          IconButton.filled(
            tooltip: label,
            onPressed: onPressed,
            style: IconButton.styleFrom(
              backgroundColor: const Color(0x88000000),
              foregroundColor: Colors.white,
            ),
            icon: Icon(icon, size: 26),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _bottomAction({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 88,
      child: Column(
        children: <Widget>[
          IconButton.filled(
            tooltip: label,
            onPressed: onPressed,
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xCC24252A),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0x6624252A),
            ),
            icon: Icon(icon),
          ),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Future<void> _pickSound() async {
    final selected = await showMusicPickerSheet(context);
    if (selected != null && mounted) setState(() => _selectedSound = selected);
  }

  Future<void> _openEditor(String path) async {
    if (!mounted) return;
    final auth = ref.read(authControllerProvider);
    final owner = auth is AuthAuthenticated
        ? (auth.user.accountId.isNotEmpty
              ? auth.user.accountId
              : auth.user.email)
        : '';
    final seed = ShortEditorSeed(
      sessionId: const Uuid().v4(),
      sourcePath: path,
      sound: _selectedSound,
      ownerId: owner,
    );
    await ref.read(shortRecorderControllerProvider.notifier).suspendCamera();
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ShortEditorScreen(seed: seed)),
    );
    _openedPath = null;
    if (mounted) {
      await ref.read(shortRecorderControllerProvider.notifier).initialize();
    }
  }

  Future<void> _offerLatestDraft() async {
    if (_checkedDraft || !mounted) return;
    _checkedDraft = true;
    final auth = ref.read(authControllerProvider);
    if (auth is! AuthAuthenticated) return;
    final owner = auth.user.accountId.isNotEmpty
        ? auth.user.accountId
        : auth.user.email;
    final repository = ref.read(shortDraftRepositoryProvider);
    await repository.prune();
    final ShortDraft? draft = await repository.latestForOwner(owner);
    if (draft == null || !mounted) return;
    final resume = await showModalBottomSheet<bool>(
      context: context,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Continue editing?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('Draft saved ${_relativeDraftTime(draft)}.'),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'Resume draft',
                style: AppTextStylesX(context).button,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Not now'),
            ),
          ],
        ),
      ),
    );
    if ((resume ?? false) && mounted) {
      await ref.read(shortRecorderControllerProvider.notifier).suspendCamera();
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ShortEditorScreen(seed: draft.toSeed()),
        ),
      );
      if (mounted) {
        await ref.read(shortRecorderControllerProvider.notifier).initialize();
      }
    }
  }

  String _relativeDraftTime(ShortDraft draft) {
    final difference = DateTime.now().toUtc().difference(draft.updatedAt);
    if (difference.inMinutes < 1) return 'just now';
    if (difference.inHours < 1) return '${difference.inMinutes} minutes ago';
    if (difference.inDays < 1) return '${difference.inHours} hours ago';
    return '${difference.inDays} days ago';
  }

  String _durationText(Duration value) {
    final minutes = value.inMinutes;
    final seconds = value.inSeconds.remainder(60);
    final tenths = (value.inMilliseconds.remainder(1000) / 100).floor();
    return '$minutes:${seconds.toString().padLeft(2, '0')}.$tenths';
  }
}

class _RecordProgressPainter extends CustomPainter {
  const _RecordProgressPainter({
    required this.progress,
    required this.recording,
  });

  final double progress;
  final bool recording;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 5;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..color = Colors.white,
    );
    if (recording) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -1.5708,
        6.2832 * progress,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 7
          ..color = Colors.red,
      );
    }
  }

  @override
  bool shouldRepaint(_RecordProgressPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.recording != recording;
}
