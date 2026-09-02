import 'dart:async';
import 'dart:typed_data';

import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/controllers/post_short_controller.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/controllers/short_mentions_controller.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/providers/short_creation_providers.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/state/upload_state.dart';
import 'package:africaonlinestores/features/shorts/create_short/presentation/helpers/post_short_media_helpers.dart';
import 'package:africaonlinestores/features/shorts/create_short/presentation/widgets/ad_picker_bottom_sheet.dart';
import 'package:africaonlinestores/features/shorts/create_short/presentation/widgets/short_sound_controls_sheet.dart';
import 'package:africaonlinestores/features/shorts/music/domain/short_sound.dart';
import 'package:africaonlinestores/features/shorts/shared/application/providers/shorts_providers.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/enums/selected_media_type.dart';
import 'package:africaonlinestores/features/social/domain/social_friend.dart';
import 'package:africaonlinestores/shared/images/app_image_decode.dart';
import 'package:africaonlinestores/shared/widgets/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PostShortDetailsScreen extends ConsumerStatefulWidget {
  const PostShortDetailsScreen({
    super.key,
    required this.media,
    required this.sessionId,
    required this.selectedSound,
  });

  final List<SelectedMedia> media;
  final String sessionId;
  final ShortSound selectedSound;

  @override
  ConsumerState<PostShortDetailsScreen> createState() =>
      _PostShortDetailsScreenState();
}

class _PostShortDetailsScreenState
    extends ConsumerState<PostShortDetailsScreen> {
  final TextEditingController _captionController = TextEditingController();
  final FocusNode _captionFocus = FocusNode();
  late final PostShortController _controller;
  final Map<String, String> _mentionAccountIds = <String, String>{};
  Uint8List? _thumbnail;
  bool _showMentions = false;
  bool _didStartPost = false;

  @override
  void initState() {
    super.initState();
    final provider = postShortControllerProvider(widget.sessionId);
    _controller = ref.read(provider.notifier);
    _captionController.addListener(_onCaptionChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller
        ..setMedia(widget.media)
        ..setSound(widget.selectedSound);
      unawaited(_generateThumbnail());
    });
  }

  @override
  void dispose() {
    _captionController
      ..removeListener(_onCaptionChanged)
      ..dispose();
    _captionFocus.dispose();
    super.dispose();
  }

  void _onCaptionChanged() {
    final value = _captionController.value;
    _controller.setCaption(value.text);
    final query = activeMentionQuery(value);
    final shouldShow = query != null;
    if (_showMentions != shouldShow && mounted) {
      setState(() => _showMentions = shouldShow);
    }
    if (query != null) {
      ref
          .read(shortMentionsControllerProvider(widget.sessionId).notifier)
          .search(query);
    }
    _mentionAccountIds.removeWhere(
      (token, _) => !captionContainsMention(value.text, token),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postShortControllerProvider(widget.sessionId));
    final mentionState = ref.watch(
      shortMentionsControllerProvider(widget.sessionId),
    );
    final isSeller =
        ref.watch(authControllerProvider).asAuthenticated?.seller.isSeller ??
        false;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Publish Short', style: context.h5),
            Text(
              'Add a caption and choose who can see it.',
              style: context.smallMuted,
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 700;
            final settings = _publishSettings(state, isSeller: isSeller);
            final composer = _captionComposer(
              state,
              mentionState: mentionState,
            );

            return Column(
              children: <Widget>[
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: wide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(flex: 4, child: _mediaPreview(state)),
                              const SizedBox(width: 24),
                              Expanded(
                                flex: 6,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    composer,
                                    const SizedBox(height: 18),
                                    settings,
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    flex: 10,
                                    child: _mediaPreview(state),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(flex: 11, child: composer),
                                ],
                              ),
                              const SizedBox(height: 18),
                              settings,
                            ],
                          ),
                  ),
                ),
                _footer(state.canUpload),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _captionComposer(
    UploadState state, {
    required ShortMentionsState mentionState,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _captionField(),
        if (_showMentions) _mentionSuggestions(mentionState),
        const SizedBox(height: 8),
        _ComposerAction(
          icon: Icons.tag_rounded,
          label: state.hashtags.isEmpty
              ? 'Hashtags'
              : 'Hashtags (${state.hashtags.length})',
          onPressed: state.isBusy ? null : _showHashtagSheet,
        ),
        if (state.hashtags.isNotEmpty) ...<Widget>[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: state.hashtags
                .map(
                  (tag) => InputChip(
                    visualDensity: VisualDensity.compact,
                    label: Text('#$tag'),
                    onDeleted: state.isBusy
                        ? null
                        : () => _controller.setHashtags(
                            state.hashtags
                                .where((item) => item != tag)
                                .toList(growable: false),
                          ),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ],
    );
  }

  Widget _publishSettings(UploadState state, {required bool isSeller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (!state.selectedSound.isOriginal) _selectedSoundRow(state),
        if (!state.selectedSound.isOriginal) const SizedBox(height: 14),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: context.appColors.border),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: <Widget>[
              _settingsRow(
                icon: Icons.public,
                title: 'Who can view',
                subtitle: audienceLabel(state.audience),
                onTap: () => _showPrivacy(state),
              ),
              const Divider(height: 1),
              _settingsRow(
                icon: Icons.tune_rounded,
                title: 'More options',
                subtitle:
                    'Comments ${state.allowComments ? 'on' : 'off'} · '
                    'Downloads ${state.allowDownloads ? 'on' : 'off'}',
                onTap: () => _showInteractionOptions(state),
              ),
            ],
          ),
        ),
        if (isSeller) ...<Widget>[
          const SizedBox(height: 18),
          Text('Tag a product', style: context.pStrong),
          const SizedBox(height: 4),
          Text(
            'Optional. Tagging one of your active products gives the backend Shop context.',
            style: context.smallMuted,
          ),
          const SizedBox(height: 10),
          state.hasSelectedAd ? _selectedAd(state) : _addProductButton(),
        ],
        if (state.errorMessage != null && !state.isBusy) ...<Widget>[
          const SizedBox(height: 14),
          Semantics(
            liveRegion: true,
            child: Text(
              state.errorMessage!,
              style: context.p.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _captionField() {
    return TextField(
      controller: _captionController,
      focusNode: _captionFocus,
      minLines: 4,
      maxLines: 7,
      maxLength: 1000,
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(
        hintText: 'Write a caption…',
        alignLabelWithHint: true,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _mediaPreview(UploadState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final previewWidth = constraints.maxWidth > 280
            ? 280.0
            : constraints.maxWidth;
        final previewHeight = (previewWidth * 16 / 9).clamp(220.0, 480.0);
        final decodeSize = AppImageDecode.forBox(
          context,
          logicalWidth: previewWidth,
          logicalHeight: previewHeight,
        );

        return Align(
          alignment: AlignmentDirectional.topCenter,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              width: previewWidth,
              height: previewHeight,
              child: ColoredBox(
                color: Colors.black,
                child: _thumbnail == null
                    ? const Center(child: CircularProgressIndicator())
                    : Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          Image.memory(
                            _thumbnail!,
                            fit: BoxFit.cover,
                            cacheWidth: decodeSize.width,
                            cacheHeight: decodeSize.height,
                          ),
                          if (!state.selectedSound.isOriginal)
                            PositionedDirectional(
                              top: 8,
                              start: 8,
                              end: 8,
                              child: Align(
                                alignment: AlignmentDirectional.topCenter,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      const Icon(
                                        Icons.music_note_rounded,
                                        size: 15,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          state.selectedSound.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          const Center(
                            child: Icon(
                              Icons.play_circle_outline_rounded,
                              color: Colors.white70,
                              size: 46,
                            ),
                          ),
                          PositionedDirectional(
                            start: 8,
                            end: 8,
                            bottom: 8,
                            child: Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: <Widget>[
                                _PreviewInfoPill(
                                  icon: Icons.schedule_rounded,
                                  label: _clipDurationLabel(),
                                  semanticLabel: 'Duration',
                                ),
                                _PreviewInfoPill(
                                  icon: Icons.public_rounded,
                                  label: audienceShortLabel(state.audience),
                                  semanticLabel: 'Visibility',
                                ),
                                _PreviewInfoPill(
                                  icon: Icons.chat_bubble_outline_rounded,
                                  label: state.allowComments ? 'On' : 'Off',
                                  semanticLabel: 'Comments',
                                ),
                                _PreviewInfoPill(
                                  icon: Icons.download_outlined,
                                  label: state.allowDownloads ? 'On' : 'Off',
                                  semanticLabel: 'Downloads',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _mentionSuggestions(ShortMentionsState state) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 180),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 240),
        margin: const EdgeInsets.only(top: 6),
        child: Material(
          color: Theme.of(context).colorScheme.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Theme.of(context).dividerColor),
          ),
          clipBehavior: Clip.antiAlias,
          child: _mentionSuggestionBody(state),
        ),
      ),
    );
  }

  Widget _mentionSuggestionBody(ShortMentionsState state) {
    if (state.isLoading) {
      return const SizedBox(
        height: 82,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.errorMessage != null && state.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            Expanded(child: Text(state.errorMessage!)),
            TextButton(
              onPressed: ref
                  .read(
                    shortMentionsControllerProvider(widget.sessionId).notifier,
                  )
                  .retry,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (state.items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(18),
        child: Text('No mentionable friends found.'),
      );
    }
    return NotificationListener<ScrollEndNotification>(
      onNotification: (notification) {
        if (notification.metrics.extentAfter < 100) {
          unawaited(
            ref
                .read(
                  shortMentionsControllerProvider(widget.sessionId).notifier,
                )
                .loadMore(),
          );
        }
        return false;
      },
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.items.length) {
            return const Padding(
              padding: EdgeInsets.all(12),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final friend = state.items[index];
          return ListTile(
            leading: CircleAvatar(child: Text(friend.initials)),
            title: Text(friend.displayName),
            subtitle: Text('@${mentionTokenForFriend(friend)}'),
            trailing: friend.isVerified
                ? const Icon(Icons.verified, size: 18)
                : null,
            onTap: () => _insertMention(friend),
          );
        },
      ),
    );
  }

  void _insertMention(SocialFriend friend) {
    final token = mentionTokenForFriend(friend);
    if (_mentionAccountIds.containsKey(token)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('That person is already mentioned.')),
      );
      return;
    }
    final result = insertShortMention(_captionController.value, friend);
    _mentionAccountIds[result.token] = result.canonicalAccountId;
    _captionController.value = result.value;
    if (mounted) setState(() => _showMentions = false);
    _captionFocus.requestFocus();
  }

  Widget _selectedSoundRow(UploadState state) {
    final sound = state.selectedSound;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      leading: const Icon(Icons.music_note_rounded),
      title: Text(sound.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        sound.artist.trim().isEmpty ? 'Selected sound' : sound.artist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.tune_rounded),
      onTap: state.isBusy ? null : () => _showSoundControls(state),
    );
  }

  Widget _settingsRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      leading: Icon(icon),
      title: Text(title, style: context.pStrong),
      subtitle: Text(subtitle, style: context.smallMuted),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }

  Future<void> _showPrivacy(UploadState state) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => ShortOptionSheet(
        title: 'Privacy settings',
        subtitle: 'Who can view this Short',
        current: state.audience,
        options: const <ShortOptionSheetItem>[
          ShortOptionSheetItem(
            'everyone',
            'Everyone',
            'Anyone can view this Short.',
          ),
          ShortOptionSheetItem(
            'followers',
            'Followers',
            'People who follow you.',
          ),
          ShortOptionSheetItem(
            'friends',
            'Friends',
            'Followers you follow back.',
          ),
          ShortOptionSheetItem(
            'only_me',
            'Only you',
            'Visible only to your account.',
          ),
        ],
      ),
    );
    if (selected != null) _controller.setAudience(selected);
  }

  Future<void> _showInteractionOptions(UploadState state) async {
    var comments = state.allowComments;
    var downloads = state.allowDownloads;
    var saveToDevice = state.saveToDevice;
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Text('More options', style: context.h5),
                          Text(
                            'Choose how people can interact.',
                            style: context.pMuted,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SwitchListTile.adaptive(
                  value: comments,
                  secondary: const Icon(Icons.chat_bubble_outline_rounded),
                  title: const Text('Allow comments'),
                  subtitle: const Text('Let viewers comment.'),
                  onChanged: (value) {
                    setSheetState(() => comments = value);
                    _controller.setAllowComments(value);
                  },
                ),
                SwitchListTile.adaptive(
                  value: downloads,
                  secondary: const Icon(Icons.download_outlined),
                  title: const Text('Allow downloads'),
                  subtitle: const Text('Let viewers save the video.'),
                  onChanged: (value) {
                    setSheetState(() => downloads = value);
                    _controller.setAllowDownloads(value);
                  },
                ),
                SwitchListTile.adaptive(
                  value: saveToDevice,
                  secondary: const Icon(Icons.save_alt_rounded),
                  title: const Text('Save to device'),
                  subtitle: const Text('Also save this video to your gallery.'),
                  onChanged: (value) {
                    setSheetState(() => saveToDevice = value);
                    _controller.setSaveToDevice(value);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showHashtagSheet() async {
    final state = ref.read(postShortControllerProvider(widget.sessionId));
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (_) => _HashtagPickerSheet(
        initialTags: state.hashtags,
        onChanged: _controller.setHashtags,
      ),
    );
  }

  Future<void> _showSoundControls(UploadState state) async {
    final result = await showShortSoundControlsSheet(
      context,
      sound: state.selectedSound,
      clipDuration: _clipDuration(),
    );
    if (result != null) _controller.setSound(result);
  }

  Widget _addProductButton() {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(58),
        alignment: Alignment.centerLeft,
      ),
      onPressed: _openAdPicker,
      icon: const Icon(Icons.sell_outlined),
      label: const Text('Tag a product (optional)'),
    );
  }

  Widget _selectedAd(UploadState state) {
    final ad = state.selectedAdPreview;
    final imageUrl = (buildFileUrl(ad?.primaryImage) ?? '').trim();
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox.square(
          dimension: 48,
          child: imageUrl.isEmpty
              ? const ColoredBox(
                  color: Colors.black12,
                  child: Icon(Icons.image_outlined),
                )
              : AppNetworkImage(
                  url: imageUrl,
                  width: 48,
                  height: 48,
                  errorBuilder: (_, _, _) => const Icon(Icons.broken_image),
                ),
        ),
      ),
      title: Text(ad?.title ?? 'Product tagged'),
      subtitle: const Text('Optional product tag'),
      onTap: _openAdPicker,
      trailing: IconButton(
        tooltip: 'Remove product',
        onPressed: _controller.clearAd,
        icon: const Icon(Icons.close),
      ),
    );
  }

  void _openAdPicker() {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        useSafeArea: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => Material(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: AdPickerBottomSheet(
            onSelected: (AOSAdListItem ad) {
              _controller.setAd(ad.id, preview: ad);
            },
          ),
        ),
      ),
    );
  }

  Widget _footer(bool canPost) {
    return Material(
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: FilledButton(
            onPressed: canPost && !_didStartPost ? _startPost : null,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
            ),
            child: Text('Post', style: AppTextStylesX(context).button),
          ),
        ),
      ),
    );
  }

  void _startPost() {
    final state = ref.read(postShortControllerProvider(widget.sessionId));
    if (_didStartPost || !state.canUpload) return;
    _didStartPost = true;
    ref.read(activeShortUploadSessionProvider.notifier).state =
        widget.sessionId;
    unawaited(_controller.upload());
    context.goNamed(AppRoutes.nFeeds, extra: 0);
  }

  Future<void> _generateThumbnail() async {
    if (widget.media.isEmpty) return;
    final thumb = await PostShortMediaHelpers.generateVideoThumbnail(
      widget.media.first.file,
    );
    if (mounted) setState(() => _thumbnail = thumb);
  }

  Duration _clipDuration() {
    if (widget.media.isEmpty) return Duration.zero;
    final seconds = widget.media.first.durationSeconds ?? 0;
    if (seconds <= 0) return Duration.zero;
    return Duration(milliseconds: (seconds * 1000).round());
  }

  String _clipDurationLabel() {
    final duration = _clipDuration();
    if (duration <= Duration.zero) return '—';
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class _PreviewInfoPill extends StatelessWidget {
  const _PreviewInfoPill({
    required this.icon,
    required this.label,
    required this.semanticLabel,
  });

  final IconData icon;
  final String label;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$semanticLabel: $label',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, color: Colors.white, size: 12),
            const SizedBox(width: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HashtagPickerSheet extends StatefulWidget {
  const _HashtagPickerSheet({
    required this.initialTags,
    required this.onChanged,
  });

  final List<String> initialTags;
  final ValueChanged<List<String>> onChanged;

  @override
  State<_HashtagPickerSheet> createState() => _HashtagPickerSheetState();
}

class _HashtagPickerSheetState extends State<_HashtagPickerSheet> {
  late final TextEditingController _textController;
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _tags = List<String>.of(widget.initialTags);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _addTag() {
    final clean = normalizeShortHashtag(_textController.text);
    if (clean == null || _tags.contains(clean) || _tags.length >= 10) return;
    setState(() {
      _tags = <String>[..._tags, clean];
      _textController.clear();
    });
    _commit();
  }

  void _removeTag(String tag) {
    setState(() {
      _tags = _tags.where((item) => item != tag).toList(growable: false);
    });
    _commit();
  }

  void _commit() {
    widget.onChanged(List<String>.unmodifiable(_tags));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Hashtags', style: context.h5),
                        Text('Add up to 10 hashtags.', style: context.pMuted),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close hashtags',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      autofocus: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _addTag(),
                      decoration: const InputDecoration(
                        prefixText: '# ',
                        hintText: 'Hashtag',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: _tags.length >= 10 ? null : _addTag,
                    child: Text('Add', style: AppTextStylesX(context).button),
                  ),
                ],
              ),
              if (_tags.isNotEmpty) ...<Widget>[
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _tags
                      .map(
                        (tag) => InputChip(
                          label: Text('#$tag'),
                          onDeleted: () => _removeTag(tag),
                        ),
                      )
                      .toList(growable: false),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ComposerAction extends StatelessWidget {
  const _ComposerAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        visualDensity: VisualDensity.compact,
      ),
      icon: Icon(icon, size: 16),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}

bool captionContainsMention(String caption, String token) {
  final escaped = RegExp.escape(token);
  final expression = RegExp(
    '(^|\\s)@$escaped(?=\\s|[.,!?]|'
    r'$'
    ')',
    caseSensitive: false,
  );
  return expression.hasMatch(caption);
}

String? activeMentionQuery(TextEditingValue value) {
  if (!value.selection.isValid || !value.selection.isCollapsed) return null;
  final cursor = value.selection.baseOffset;
  if (cursor < 0 || cursor > value.text.length) return null;
  final before = value.text.substring(0, cursor);
  final match = RegExp(r'(?:^|\s)@([A-Za-z0-9._+-]*)$').firstMatch(before);
  return match?.group(1);
}

String? normalizeShortHashtag(String value) {
  final clean = value.trim().replaceFirst(RegExp('^#+'), '').toLowerCase();
  if (clean.isEmpty || clean.contains(RegExp(r'\s'))) return null;
  return clean;
}

String audienceLabel(String value) => switch (value) {
  'followers' => 'Followers',
  'friends' => 'Friends',
  'only_me' => 'Only you',
  _ => 'Everyone',
};

String audienceShortLabel(String value) => switch (value) {
  'followers' => 'Followers',
  'friends' => 'Friends',
  'only_me' => 'Only me',
  _ => 'Everyone',
};

class ShortOptionSheetItem {
  const ShortOptionSheetItem(this.value, this.title, this.subtitle);
  final String value;
  final String title;
  final String subtitle;
}

class ShortOptionSheet extends StatelessWidget {
  const ShortOptionSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.current,
    required this.options,
  });

  final String title;
  final String subtitle;
  final String current;
  final List<ShortOptionSheetItem> options;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: context.h5,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Text(subtitle, style: context.pStrong),
            const SizedBox(height: 8),
            RadioGroup<String>(
              groupValue: current,
              onChanged: (String? value) {
                if (value != null) Navigator.pop(context, value);
              },
              child: Column(
                children: options
                    .map(
                      (option) => RadioListTile<String>(
                        value: option.value,
                        title: Text(option.title),
                        subtitle: Text(option.subtitle),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
