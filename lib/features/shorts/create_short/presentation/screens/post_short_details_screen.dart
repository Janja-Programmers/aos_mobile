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
      ref.read(shortMentionsControllerProvider.notifier).search(query);
    }
    _mentionAccountIds.removeWhere(
      (token, _) => !captionContainsMention(value.text, token),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postShortControllerProvider(widget.sessionId));
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
            final content = _publishContent(state, isSeller: isSeller);
            final preview = _mediaPreview(state);
            return Column(
              children: <Widget>[
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                    child: wide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(flex: 4, child: preview),
                              const SizedBox(width: 24),
                              Expanded(flex: 6, child: content),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              preview,
                              const SizedBox(height: 20),
                              content,
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

  Widget _publishContent(UploadState state, {required bool isSeller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _captionField(),
        if (_showMentions) _mentionSuggestions(),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            ActionChip(
              avatar: const Icon(Icons.tag_rounded, size: 18),
              label: Text(
                state.hashtags.isEmpty
                    ? 'Hashtags'
                    : 'Hashtags (${state.hashtags.length})',
              ),
              onPressed: state.isBusy ? null : _showHashtagSheet,
            ),
            ActionChip(
              avatar: const Icon(Icons.alternate_email_rounded, size: 18),
              label: const Text('Mention'),
              onPressed: state.isBusy ? null : _showMentionSheet,
            ),
          ],
        ),
        if (state.hashtags.isNotEmpty) ...<Widget>[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: state.hashtags
                .map(
                  (tag) => InputChip(
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
        if (!state.selectedSound.isOriginal) ...<Widget>[
          const SizedBox(height: 16),
          _selectedSoundRow(state),
        ],
        const SizedBox(height: 18),
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
          const SizedBox(height: 20),
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
      minLines: 5,
      maxLines: 8,
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
    final availableWidth = MediaQuery.sizeOf(context).width - 40;
    final previewWidth = availableWidth.clamp(180, 360).toDouble();
    final previewHeight = (previewWidth * 16 / 9).clamp(280, 540).toDouble();
    final AppImageDecodeSize decodeSize = AppImageDecode.forBox(
      context,
      logicalWidth: previewWidth,
      logicalHeight: previewHeight,
    );
    return Align(
      alignment: AlignmentDirectional.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
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
                              top: 12,
                              start: 12,
                              end: 12,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
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
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          state.selectedSound.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
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
                              size: 58,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _InfoBadge(label: 'Duration', value: _clipDurationLabel()),
              _InfoBadge(
                label: 'Visibility',
                value: audienceShortLabel(state.audience),
              ),
              _InfoBadge(
                label: 'Comments',
                value: state.allowComments ? 'Allowed' : 'Off',
              ),
              _InfoBadge(
                label: 'Downloads',
                value: state.allowDownloads ? 'Allowed' : 'Off',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mentionSuggestions() {
    final state = ref.watch(shortMentionsControllerProvider);
    return AnimatedSize(
      duration: const Duration(milliseconds: 180),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 240),
        margin: const EdgeInsets.only(top: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: _mentionSuggestionBody(state),
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
                  .read(shortMentionsControllerProvider.notifier)
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
            ref.read(shortMentionsControllerProvider.notifier).loadMore(),
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
    final initial = ref
        .read(postShortControllerProvider(widget.sessionId))
        .hashtags
        .toList(growable: true);
    final text = TextEditingController();
    var tags = initial;
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          void addTag() {
            final clean = normalizeShortHashtag(text.text);
            if (clean == null || tags.contains(clean) || tags.length >= 10) {
              return;
            }
            setSheetState(() {
              tags = <String>[...tags, clean];
              text.clear();
            });
            _controller.setHashtags(tags);
          }

          return Padding(
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
                            Text(
                              'Add up to 10 hashtags.',
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
                  const SizedBox(height: 14),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: text,
                          autofocus: true,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => addTag(),
                          decoration: const InputDecoration(
                            prefixText: '# ',
                            hintText: 'Hashtag',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      FilledButton(
                        onPressed: tags.length >= 10 ? null : addTag,
                        child: Text(
                          'Add',
                          style: AppTextStylesX(context).button,
                        ),
                      ),
                    ],
                  ),
                  if (tags.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tags
                          .map((tag) {
                            return InputChip(
                              label: Text('#$tag'),
                              onDeleted: () {
                                setSheetState(
                                  () => tags = tags
                                      .where((item) => item != tag)
                                      .toList(growable: true),
                                );
                                _controller.setHashtags(tags);
                              },
                            );
                          })
                          .toList(growable: false),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
    text.dispose();
  }

  Future<void> _showMentionSheet() async {
    final search = TextEditingController();
    ref.read(shortMentionsControllerProvider.notifier).search('');
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (sheetContext) => Consumer(
        builder: (context, ref, _) {
          final state = ref.watch(shortMentionsControllerProvider);
          return Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              MediaQuery.viewInsetsOf(context).bottom + 20,
            ),
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height * .62,
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Mention someone', style: context.h5),
                            Text(
                              'Find someone to mention.',
                              style: context.pMuted,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: search,
                    autofocus: true,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.alternate_email_rounded),
                      hintText: 'Search people',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      final clean = value.trim();
                      if (clean.length >= 2) {
                        ref
                            .read(shortMentionsControllerProvider.notifier)
                            .search(clean);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: search.text.trim().length < 2
                        ? const Center(
                            child: Text('Type at least two characters.'),
                          )
                        : _mentionModalResults(state, sheetContext),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    search.dispose();
  }

  Widget _mentionModalResults(
    ShortMentionsState state,
    BuildContext sheetContext,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.errorMessage != null && state.items.isEmpty) {
      return Center(child: Text(state.errorMessage!));
    }
    if (state.items.isEmpty) {
      return const Center(child: Text('No people found.'));
    }
    return NotificationListener<ScrollEndNotification>(
      onNotification: (notification) {
        if (notification.metrics.extentAfter < 100) {
          unawaited(
            ref.read(shortMentionsControllerProvider.notifier).loadMore(),
          );
        }
        return false;
      },
      child: ListView.builder(
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
            onTap: () {
              Navigator.pop(sheetContext);
              _insertMention(friend);
            },
          );
        },
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

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 100),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.appColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: AppTextStylesX(context).caption),
          Text(value, style: context.pStrong),
        ],
      ),
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
