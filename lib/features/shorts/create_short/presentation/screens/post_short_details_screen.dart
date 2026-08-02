import 'dart:async';
import 'dart:typed_data';

import 'package:africaonlinestores/core/routing/helpers/app_routes.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/controllers/post_short_controller.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/controllers/short_mentions_controller.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/providers/short_creation_providers.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/state/post_category_options.dart';
import 'package:africaonlinestores/features/shorts/create_short/application/state/upload_state.dart';
import 'package:africaonlinestores/features/shorts/create_short/presentation/helpers/post_short_media_helpers.dart';
import 'package:africaonlinestores/features/shorts/create_short/presentation/widgets/ad_picker_bottom_sheet.dart';
import 'package:africaonlinestores/features/shorts/music/domain/short_sound.dart';
import 'package:africaonlinestores/features/shorts/shared/application/providers/shorts_providers.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short_content_modes.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/enums/selected_media_type.dart';
import 'package:africaonlinestores/features/social/domain/social_friend.dart';
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
  final TextEditingController _hashtagController = TextEditingController();
  final FocusNode _captionFocus = FocusNode();
  late final ProviderSubscription<UploadState> _uploadSubscription;
  late final PostShortController _controller;
  late PostCategoryOption _selectedCategory;
  final Map<String, String> _mentionAccountIds = <String, String>{};
  Uint8List? _thumbnail;
  bool _showMentions = false;
  bool _didRedirect = false;
  bool _failureDismissed = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = postCategoriesData.firstWhere(
      (item) => item.contentMode == ShortContentModes.geo,
      orElse: () => postCategoriesData.first,
    );
    final provider = postShortControllerProvider(widget.sessionId);
    _controller = ref.read(provider.notifier);
    _uploadSubscription = ref.listenManual<UploadState>(
      provider,
      _onUploadStateChanged,
    );
    _captionController.addListener(_onCaptionChanged);
    _hashtagController.addListener(_onHashtagsChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller
        ..setMedia(widget.media)
        ..setSound(widget.selectedSound)
        ..setContentMode(_selectedCategory.contentMode);
      unawaited(_generateThumbnail());
    });
  }

  @override
  void dispose() {
    _uploadSubscription.close();
    _captionController
      ..removeListener(_onCaptionChanged)
      ..dispose();
    _hashtagController
      ..removeListener(_onHashtagsChanged)
      ..dispose();
    _captionFocus.dispose();
    super.dispose();
  }

  void _onUploadStateChanged(UploadState? previous, UploadState next) {
    if (next.status == UploadStatus.failed &&
        previous?.status != UploadStatus.failed &&
        mounted) {
      setState(() => _failureDismissed = false);
    }
    if (next.isBusy || next.status == UploadStatus.ready) {
      ref.read(activeShortUploadSessionProvider.notifier).state =
          widget.sessionId;
    }
    if (!_didRedirect &&
        next.status == UploadStatus.processing &&
        previous?.status != UploadStatus.processing) {
      _didRedirect = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.goNamed(AppRoutes.nFeeds, extra: 0);
      });
    }
    if (next.status == UploadStatus.ready &&
        previous?.status != UploadStatus.ready) {
      unawaited(ref.read(shortsControllerProvider.notifier).loadInitial());
    }
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

  void _onHashtagsChanged() {
    final tags = _hashtagController.text
        .split(RegExp(r'[\s,]+'))
        .where((item) => item.trim().isNotEmpty)
        .toList(growable: false);
    _controller.setHashtags(tags);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postShortControllerProvider(widget.sessionId));
    final canPost = state.canUpload;
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('New Post')),
      body: Stack(
        children: <Widget>[
          SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _mediaPreview(),
                        const SizedBox(height: 20),
                        Text('Category *', style: context.pStrong),
                        const SizedBox(height: 10),
                        _categorySelector(state),
                        const SizedBox(height: 18),
                        _captionField(),
                        if (_showMentions) _mentionSuggestions(),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _hashtagController,
                          maxLength: 160,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            hintText:
                                '#hashtags (e.g. #fashion #deals #trending)',
                            counterText: '',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        if (!state.selectedSound.isOriginal) ...<Widget>[
                          const SizedBox(height: 14),
                          _selectedSoundRow(state.selectedSound),
                        ],
                        const SizedBox(height: 14),
                        _settingsRow(
                          icon: Icons.public,
                          title: audienceLabel(state.audience),
                          onTap: () => _showPrivacy(state),
                        ),
                        const Divider(height: 1),
                        _settingsRow(
                          icon: Icons.settings_outlined,
                          title: 'More options',
                          onTap: () => _showInteractionOptions(state),
                        ),
                        if (state.requiresAd) ...<Widget>[
                          const SizedBox(height: 18),
                          Text('Product *', style: context.pStrong),
                          const SizedBox(height: 8),
                          state.hasSelectedAd
                              ? _selectedAd(state)
                              : _addProductButton(),
                        ],
                        if (state.errorMessage != null &&
                            !state.isBusy) ...<Widget>[
                          const SizedBox(height: 14),
                          Text(
                            state.errorMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                _footer(canPost),
              ],
            ),
          ),
          if (state.isBusy ||
              (state.status == UploadStatus.failed && !_failureDismissed))
            _uploadOverlay(state),
        ],
      ),
    );
  }

  Widget _mediaPreview() {
    final availableWidth = MediaQuery.sizeOf(context).width - 40;
    final previewSize = availableWidth.clamp(160, 240).toDouble();
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox.square(
          dimension: previewSize,
          child: ColoredBox(
            color: Colors.black,
            child: _thumbnail == null
                ? const Center(child: CircularProgressIndicator())
                : Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      Image.memory(_thumbnail!, fit: BoxFit.cover),
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
    );
  }

  Widget _categorySelector(UploadState state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: postCategoriesData
            .map((category) {
              final selected = category.id == _selectedCategory.id;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  selected: selected,
                  avatar: Icon(category.icon, size: 18),
                  label: Text(category.label),
                  onSelected: state.isBusy
                      ? null
                      : (_) {
                          setState(() => _selectedCategory = category);
                          _controller.setContentMode(category.contentMode);
                        },
                ),
              );
            })
            .toList(growable: false),
      ),
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
        hintText:
            "What's on your mind? Describe your post, share a story, or tell people about your product…",
        alignLabelWithHint: true,
        border: OutlineInputBorder(),
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
    setState(() => _showMentions = false);
    _captionFocus.requestFocus();
  }

  Widget _selectedSoundRow(ShortSound sound) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      leading: const Icon(Icons.music_note_rounded),
      title: Text(sound.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        sound.artist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Tooltip(
        message: 'Sound is selected in the editor',
        child: Icon(Icons.lock_outline_rounded),
      ),
    );
  }

  Widget _settingsRow({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(icon),
      title: Text(title, style: context.pStrong),
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
        subtitle: 'Who can view this post',
        current: state.audience,
        options: const <ShortOptionSheetItem>[
          ShortOptionSheetItem(
            'everyone',
            'Everyone',
            'Anyone can view this post.',
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Expanded(
                    child: Text(
                      'More options',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              SwitchListTile.adaptive(
                value: comments,
                title: const Text('Allow comments'),
                subtitle: const Text('Let viewers comment on your post.'),
                onChanged: (value) {
                  setSheetState(() => comments = value);
                  _controller.setAllowComments(value);
                },
              ),
              SwitchListTile.adaptive(
                value: downloads,
                title: const Text('Allow downloading'),
                subtitle: const Text('Let viewers download this video.'),
                onChanged: (value) {
                  setSheetState(() => downloads = value);
                  _controller.setAllowDownloads(value);
                },
              ),
              SwitchListTile.adaptive(
                value: saveToDevice,
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
    );
  }

  Widget _addProductButton() {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(58),
        alignment: Alignment.centerLeft,
      ),
      onPressed: _openAdPicker,
      icon: const Icon(Icons.sell_outlined),
      label: const Text('Tag a product (required)'),
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
              : Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Icon(Icons.broken_image),
                ),
        ),
      ),
      title: Text(ad?.title ?? 'Product tagged'),
      subtitle: Text(state.selectedAdId ?? ''),
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
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FilledButton(
                onPressed: canPost ? _controller.upload : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                ),
                child: const Text('Post'),
              ),
              const SizedBox(height: 8),
              const Text(
                'I confirm that there are no private messages in my content',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _uploadOverlay(UploadState state) {
    final failed = state.status == UploadStatus.failed;
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black54,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Material(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        failed
                            ? Icons.error_outline
                            : Icons.cloud_upload_outlined,
                        size: 68,
                        color: failed
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        uploadStageTitle(state),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 18),
                      if (!failed)
                        LinearProgressIndicator(
                          value: state.status == UploadStatus.uploading
                              ? state.progress.clamp(0, 1).toDouble()
                              : state.status == UploadStatus.publishing ||
                                    state.status == UploadStatus.processing
                              ? null
                              : 0,
                        ),
                      if (state.status == UploadStatus.uploading) ...<Widget>[
                        const SizedBox(height: 10),
                        Text(
                          '${(state.progress * 100).clamp(0, 100).round()}%',
                        ),
                      ],
                      if (failed) ...<Widget>[
                        const SizedBox(height: 8),
                        Text(
                          state.errorMessage ?? 'Publishing failed.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 18),
                        if (state.shortId != null)
                          FilledButton(
                            onPressed: _controller.retryProcessingCurrent,
                            child: const Text('Retry processing'),
                          )
                        else
                          FilledButton(
                            onPressed: _controller.upload,
                            child: const Text('Retry upload'),
                          ),
                        TextButton(
                          onPressed: () {
                            ref
                                    .read(
                                      activeShortUploadSessionProvider.notifier,
                                    )
                                    .state =
                                null;
                            setState(() => _failureDismissed = true);
                          },
                          child: const Text('Close'),
                        ),
                      ] else if (state.status ==
                          UploadStatus.uploading) ...<Widget>[
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _controller.cancelUpload,
                          child: const Text('Cancel'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _generateThumbnail() async {
    if (widget.media.isEmpty) return;
    final thumb = await PostShortMediaHelpers.generateVideoThumbnail(
      widget.media.first.file,
    );
    if (mounted) setState(() => _thumbnail = thumb);
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

String audienceLabel(String value) => switch (value) {
  'followers' => 'Followers can view this post',
  'friends' => 'Friends can view this post',
  'only_me' => 'Only you can view this post',
  _ => 'Everyone can view this post',
};

String uploadStageTitle(UploadState state) => switch (state.status) {
  UploadStatus.initializing => 'Preparing your upload',
  UploadStatus.uploading => 'Uploading your short',
  UploadStatus.confirming => 'Confirming your upload',
  UploadStatus.publishing => 'Publishing your short',
  UploadStatus.processing => 'Publishing continues in the background',
  UploadStatus.failed => 'Your short was not published',
  UploadStatus.ready => 'Your short is ready',
  UploadStatus.idle || UploadStatus.picked => 'Preparing your short',
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
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Text(subtitle, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            RadioGroup<String>(
              groupValue: current,
              onChanged: (String? value) {
                if (value != null) {
                  Navigator.pop(context, value);
                }
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
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
