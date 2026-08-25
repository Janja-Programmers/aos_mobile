import 'dart:async';
import 'dart:io';

import 'package:africaonlinestores/core/media/application/media_services_provider.dart';
import 'package:africaonlinestores/core/media/domain/media_asset.dart';
import 'package:africaonlinestores/core/media/domain/media_policy.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/core/utils/media_url.dart';
import 'package:africaonlinestores/features/account/domain/account_profile_snapshot.dart';
import 'package:africaonlinestores/features/account/domain/account_state.dart';
import 'package:africaonlinestores/features/account/shared/providers/accounts_controller.dart';
import 'package:africaonlinestores/features/live/application/providers/live_providers.dart';
import 'package:africaonlinestores/features/live/application/services/live_media_service.dart';
import 'package:africaonlinestores/features/live/presentation/widgets/go_live_details_sheet.dart';
import 'package:africaonlinestores/features/live/presentation/widgets/live_video_stage.dart';
import 'package:africaonlinestores/l10n/l10n_extension.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

class GoLiveScreen extends ConsumerStatefulWidget {
  const GoLiveScreen({super.key});

  @override
  ConsumerState<GoLiveScreen> createState() => _GoLiveScreenState();
}

class _GoLiveScreenState extends ConsumerState<GoLiveScreen> {
  final _titleController = TextEditingController();
  late final ProviderSubscription<AccountState> _accountSubscription;
  late final AppLifecycleListener _lifecycleListener;
  late final LiveMediaService _liveMediaService;

  AcquiredMedia? _selectedCoverMedia;
  AcquiredMedia? _pendingCoverMedia;
  String? _uploadedImageUrl;
  String? _uploadedCoverMediaId;
  String? _profileCoverImageUrl;
  String _profileDisplayName = '';
  lk.LocalVideoTrack? _previewTrack;

  bool _isUploading = false;
  bool _isStartingPreview = false;
  bool _isMicMuted = false;
  bool _isCountingDown = false;
  int? _countdown;

  bool _isFlippingCamera = false;
  bool _isFrontCamera = true;
  bool _previewTransferred = false;
  bool _isApplyingTitleDefault = false;
  bool _titleWasEdited = false;
  int _previewGeneration = 0;

  File? get _selectedImage => _selectedCoverMedia?.file;

  @override
  void initState() {
    super.initState();
    _liveMediaService = ref.read(liveMediaServiceProvider);
    _titleController.addListener(_onTitleChanged);
    _applyProfileDefaults(ref.read(accountsControllerProvider), notify: false);
    _accountSubscription = ref.listenManual<AccountState>(
      accountsControllerProvider,
      (_, next) => _applyProfileDefaults(next),
    );
    _lifecycleListener = AppLifecycleListener(
      onInactive: _pausePreviewForLifecycle,
      onPause: _pausePreviewForLifecycle,
      onDetach: _pausePreviewForLifecycle,
      onResume: _resumePreviewForLifecycle,
    );
    unawaited(_startCameraPreview());
  }

  void _pausePreviewForLifecycle() {
    if (_previewTransferred) return;
    unawaited(_suspendCameraPreview());
  }

  void _resumePreviewForLifecycle() {
    if (_previewTransferred || _isCountingDown) return;
    unawaited(_startCameraPreview());
  }

  void _onTitleChanged() {
    if (!_isApplyingTitleDefault) _titleWasEdited = true;
  }

  void _applyProfileDefaults(AccountState accountState, {bool notify = true}) {
    final profile = AccountProfileSnapshot.fromJson(accountState.profile);
    final displayName = profile.fullName.trim();
    final coverImageUrl = normalizeMediaUrl(profile.userImage);

    if (!_titleWasEdited && displayName.isNotEmpty) {
      final defaultTitle = String.fromCharCodes(
        displayName.runes.take(goLiveTitleMaxLength),
      );
      _isApplyingTitleDefault = true;
      _titleController.value = TextEditingValue(
        text: defaultTitle,
        selection: TextSelection.collapsed(offset: defaultTitle.length),
      );
      _isApplyingTitleDefault = false;
    }

    final nextDisplayName = displayName.isEmpty
        ? _profileDisplayName
        : displayName;
    final changed =
        nextDisplayName != _profileDisplayName ||
        coverImageUrl != _profileCoverImageUrl;
    _profileDisplayName = nextDisplayName;
    _profileCoverImageUrl = coverImageUrl;

    if (notify && mounted && changed) setState(() {});
  }

  Future<void> _startCameraPreview() async {
    if (_isStartingPreview || _previewTrack != null) return;
    final generation = ++_previewGeneration;

    setState(() => _isStartingPreview = true);

    try {
      final track = await _liveMediaService.prepareCamera(
        frontCamera: _isFrontCamera,
      );

      if (!mounted || generation != _previewGeneration) {
        await _liveMediaService.releasePreparedCamera();
        return;
      }

      setState(() {
        _previewTrack = track;
        _isStartingPreview = false;
      });
    } on Object catch (error, stackTrace) {
      appLogger.e(
        'Live camera preview failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;

      setState(() => _isStartingPreview = false);
      ShowSnack(context, context.l10n.liveCameraStartError).error();
    }
  }

  Future<void> _suspendCameraPreview() async {
    _previewGeneration += 1;
    if (mounted) {
      setState(() {
        _previewTrack = null;
        _isStartingPreview = false;
      });
    } else {
      _previewTrack = null;
      _isStartingPreview = false;
    }
    await _liveMediaService.releasePreparedCamera();
  }

  Future<void> _flipPreviewCamera() async {
    if (_previewTrack == null || _isFlippingCamera || _isStartingPreview) {
      return;
    }

    setState(() => _isFlippingCamera = true);

    try {
      final switched = await _liveMediaService.flipCamera();
      if (!mounted) return;
      if (!switched) {
        ShowSnack(context, context.l10n.liveNoAlternateCameraError).error();
        return;
      }
      setState(() => _isFrontCamera = !_isFrontCamera);
    } on Object catch (error, stackTrace) {
      appLogger.e(
        'Live preview camera flip failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      ShowSnack(context, context.l10n.liveCameraFlipError).error();
    } finally {
      if (mounted) {
        setState(() => _isFlippingCamera = false);
      }
    }
  }

  Future<void> _showDetailsEditor() async {
    if (_isUploading || _isCountingDown) return;

    final draft = await showModalBottomSheet<GoLiveDetailsDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GoLiveDetailsSheet(
        initialTitle: _titleController.text,
        displayName: _profileDisplayName,
        coverImageUrl: _effectiveCoverImageUrl,
        coverImage: _selectedImage,
        pickCover: _pickCover,
      ),
    );

    if (!mounted || draft == null) {
      await _pendingCoverMedia?.discard();
      _pendingCoverMedia = null;
      return;
    }

    _titleWasEdited = true;
    _titleController.value = TextEditingValue(
      text: draft.title,
      selection: TextSelection.collapsed(offset: draft.title.length),
    );

    final nextImage = draft.coverImage;
    if (nextImage != null && nextImage.path != _selectedImage?.path) {
      final selected = _pendingCoverMedia?.path == nextImage.path
          ? _pendingCoverMedia
          : AcquiredMedia.external(file: nextImage, kind: MediaKind.image);
      _pendingCoverMedia = null;
      if (selected != null) await _uploadCoverImage(selected);
    }
  }

  Future<File?> _pickCover(BuildContext pickerContext) async {
    final source = await showModalBottomSheet<MediaAcquisitionSource>(
      context: pickerContext,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(sheetContext.l10n.liveChooseCoverFromGallery),
                onTap: () =>
                    Navigator.pop(sheetContext, MediaAcquisitionSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: Text(sheetContext.l10n.liveTakeCoverPhoto),
                onTap: () =>
                    Navigator.pop(sheetContext, MediaAcquisitionSource.camera),
              ),
            ],
          ),
        );
      },
    );
    if (source == null || !pickerContext.mounted) return null;

    try {
      final acquisition = ref.read(mediaAcquisitionServiceProvider);
      if (source == MediaAcquisitionSource.camera) {
        await _suspendCameraPreview();
        if (!pickerContext.mounted) return null;
      }
      final media = source == MediaAcquisitionSource.camera
          ? await acquisition.captureImage(
              pickerContext,
              useCase: MediaUseCase.liveCover,
            )
          : await acquisition.pickImage(useCase: MediaUseCase.liveCover);
      if (media == null) return null;
      await _pendingCoverMedia?.discard();
      _pendingCoverMedia = media;
      return media.file;
    } on Object catch (error, stackTrace) {
      appLogger.e(
        'Live cover selection failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (pickerContext.mounted) {
        ShowSnack(
          pickerContext,
          pickerContext.l10n.liveCoverSelectionError,
        ).error();
      }
      return null;
    } finally {
      if (source == MediaAcquisitionSource.camera &&
          mounted &&
          !_previewTransferred) {
        unawaited(_startCameraPreview());
      }
    }
  }

  Future<void> _uploadCoverImage(AcquiredMedia media) async {
    final previousMedia = _selectedCoverMedia;
    final previousUrl = _uploadedImageUrl;
    final previousMediaId = _uploadedCoverMediaId;

    setState(() {
      _selectedCoverMedia = media;
      _uploadedImageUrl = null;
      _uploadedCoverMediaId = null;
      _isUploading = true;
    });

    final upload = await ref
        .read(mediaUploadCoordinatorProvider)
        .upload(media: media, useCase: MediaUseCase.liveCover);
    final uploaded = upload.rightOrNull;

    if (!mounted) return;

    if (uploaded == null || uploaded.mediaId.trim().isEmpty) {
      setState(() {
        _selectedCoverMedia = previousMedia;
        _uploadedImageUrl = previousUrl;
        _uploadedCoverMediaId = previousMediaId;
        _isUploading = false;
      });
      if (!identical(media, previousMedia)) await media.discard();
      if (!mounted) return;
      ShowSnack(context, context.l10n.liveCoverUploadError).error();
      return;
    }

    setState(() {
      _isUploading = false;
      _uploadedImageUrl = normalizeMediaUrl(uploaded.url);
      _uploadedCoverMediaId = uploaded.mediaId.trim();
    });
    if (!identical(previousMedia, media)) await previousMedia?.discard();
  }

  String? get _effectiveCoverImageUrl {
    final uploaded = _uploadedImageUrl?.trim() ?? '';
    if (uploaded.isNotEmpty) return uploaded;
    return _profileCoverImageUrl;
  }

  Future<void> _startLive() async {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      ShowSnack(context, context.l10n.liveTitleRequired).error();
      return;
    }

    if (_isCountingDown || _isUploading || _isFlippingCamera) return;

    setState(() {
      _isCountingDown = true;
      _countdown = 3;
    });

    for (var i = 3; i >= 1; i--) {
      if (!mounted) return;
      setState(() => _countdown = i);
      await Future<void>.delayed(const Duration(seconds: 1));
    }

    if (!mounted) return;

    setState(() => _countdown = null);

    final hadPreviewCamera = _previewTrack != null;
    final micEnabled = !_isMicMuted;
    final frontCamera = _isFrontCamera;
    _previewTransferred = true;

    final started = await ref
        .read(liveManagerProvider.notifier)
        .startLive(
          title: title,
          coverImage: _effectiveCoverImageUrl,
          coverMediaId: _uploadedCoverMediaId,
          micEnabled: micEnabled,
          cameraEnabled: hadPreviewCamera,
          frontCamera: frontCamera,
        );

    if (mounted) {
      setState(() {
        _isCountingDown = false;
        _previewTransferred = started;
        if (!started) _previewTrack = null;
      });
      if (!started) unawaited(_startCameraPreview());
    }
  }

  @override
  void dispose() {
    _accountSubscription.close();
    _lifecycleListener.dispose();
    _titleController.removeListener(_onTitleChanged);
    _titleController.dispose();
    unawaited(_pendingCoverMedia?.discard());
    if (!identical(_pendingCoverMedia, _selectedCoverMedia)) {
      unawaited(_selectedCoverMedia?.discard());
    }
    if (!_previewTransferred) {
      unawaited(_liveMediaService.releasePreparedCamera());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: LiveVideoStage(
              track: _previewTrack,
              emptyLabel: _isStartingPreview || _isFlippingCamera
                  ? context.l10n.liveCameraStarting
                  : context.l10n.liveCameraUnavailable,
              mirror: _isFrontCamera,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colors.black.withValues(alpha: .50),
                    Colors.transparent,
                    colors.black.withValues(alpha: .85),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight > 32
                          ? constraints.maxHeight - 32
                          : 0,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              IconButton.filled(
                                tooltip: MaterialLocalizations.of(
                                  context,
                                ).closeButtonTooltip,
                                style: IconButton.styleFrom(
                                  backgroundColor: colors.black.withValues(
                                    alpha: .45,
                                  ),
                                ),
                                onPressed: _close,
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                              ),
                              const Spacer(),
                              IconButton.filled(
                                key: const Key('go_live_flip_camera'),
                                tooltip: context.l10n.liveFlipCameraAction,
                                onPressed: _isFlippingCamera
                                    ? null
                                    : _flipPreviewCamera,
                                icon: Icon(
                                  Icons.cameraswitch_outlined,
                                  color: colors.btnText,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton.filled(
                                key: const Key('go_live_mute'),
                                tooltip: _isMicMuted
                                    ? context.l10n.liveUnmuteAction
                                    : context.l10n.liveMuteAction,
                                onPressed: _isFlippingCamera
                                    ? null
                                    : () => setState(
                                        () => _isMicMuted = !_isMicMuted,
                                      ),
                                icon: Icon(
                                  _isMicMuted
                                      ? Icons.mic_off_outlined
                                      : Icons.mic_none_outlined,
                                  color: colors.btnText,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          _buildSetupCard(context),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_countdown != null)
            Positioned.fill(
              child: ColoredBox(
                color: colors.black.withValues(alpha: .42),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: Text(
                      '$_countdown',
                      key: ValueKey(_countdown),
                      style: context.display.copyWith(
                        color: Colors.white,
                        fontSize: 92,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSetupCard(BuildContext context) {
    final colors = context.appColors;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _titleController,
      builder: (context, titleValue, _) {
        final title = titleValue.text.trim();
        final hasTitle = title.isNotEmpty;
        final blocked =
            !hasTitle || _isUploading || _isCountingDown || _isFlippingCamera;
        final String subtitle;
        if (_isUploading) {
          subtitle = context.l10n.liveUploadingCover;
        } else if (!hasTitle) {
          subtitle = context.l10n.liveTitleRequired;
        } else {
          subtitle = context.l10n.liveEditDetailsHint;
        }

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.black.withValues(alpha: .54),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: .16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                button: true,
                enabled: !_isUploading && !_isCountingDown,
                label: context.l10n.liveEditDetailsAction,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    key: const Key('go_live_edit_details'),
                    borderRadius: BorderRadius.circular(18),
                    onTap: _isUploading || _isCountingDown
                        ? null
                        : _showDetailsEditor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              LiveCoverPreview(
                                key: const Key('go_live_cover_preview'),
                                width: 56,
                                height: 56,
                                imageFile: _selectedImage,
                                imageUrl: _effectiveCoverImageUrl,
                                displayName: _profileDisplayName.isEmpty
                                    ? title
                                    : _profileDisplayName,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              if (_isUploading)
                                const SizedBox.square(
                                  dimension: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  hasTitle
                                      ? title
                                      : context.l10n.liveTitleLabel,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.pStrong.copyWith(
                                    color: colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  subtitle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStylesX(
                                    context,
                                  ).caption.copyWith(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Tooltip(
                            message: context.l10n.liveEditDetailsAction,
                            child: Icon(
                              Icons.edit_outlined,
                              color: colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  key: const Key('go_live_button'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.btnText,
                    disabledBackgroundColor: colors.primary.withValues(
                      alpha: .45,
                    ),
                    disabledForegroundColor: colors.btnText.withValues(
                      alpha: .75,
                    ),
                    minimumSize: const Size.fromHeight(52),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: blocked ? null : _startLive,
                  child: Text(
                    _isCountingDown
                        ? context.l10n.liveStartingAction
                        : context.l10n.liveGoLiveAction,
                    style: AppTextStylesX(
                      context,
                    ).button.copyWith(color: colors.btnText),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _close() {
    unawaited(_closeAsync());
  }

  Future<void> _closeAsync() async {
    await Navigator.of(context).maybePop();
  }
}
