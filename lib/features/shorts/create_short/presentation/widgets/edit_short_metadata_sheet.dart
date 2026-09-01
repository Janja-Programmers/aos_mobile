import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/ads/domain/aos_ad.dart';
import 'package:africaonlinestores/features/auth/shared/providers/auth_controller_provider.dart';
import 'package:africaonlinestores/features/shorts/create_short/presentation/widgets/ad_picker_bottom_sheet.dart';
import 'package:africaonlinestores/features/shorts/create_short/presentation/widgets/short_sound_controls_sheet.dart';
import 'package:africaonlinestores/features/shorts/music/domain/short_sound.dart';
import 'package:africaonlinestores/features/shorts/music/presentation/music_picker_sheet.dart';
import 'package:africaonlinestores/features/shorts/shared/application/providers/shorts_providers.dart';
import 'package:africaonlinestores/features/shorts/shared/domain/entities/short.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<bool> showEditShortMetadataSheet(
  BuildContext context, {
  required Short short,
}) async {
  return await showModalBottomSheet<bool>(
        context: context,
        useSafeArea: true,
        isScrollControlled: true,
        builder: (_) => _EditShortMetadataSheet(short: short),
      ) ??
      false;
}

class _EditShortMetadataSheet extends ConsumerStatefulWidget {
  const _EditShortMetadataSheet({required this.short});

  final Short short;

  @override
  ConsumerState<_EditShortMetadataSheet> createState() =>
      _EditShortMetadataSheetState();
}

class _EditShortMetadataSheetState
    extends ConsumerState<_EditShortMetadataSheet> {
  late final TextEditingController _caption;
  late List<String> _hashtags;
  late String _audience;
  late bool _allowComments;
  late bool _allowDownloads;
  late ShortSound _sound;
  String? _selectedAdId;
  String? _selectedAdTitle;
  bool _adTouched = false;
  bool _saving = false;
  String? _error;

  Short get short => widget.short;

  @override
  void initState() {
    super.initState();
    _caption = TextEditingController(text: short.caption.toString());
    _hashtags = short.hashtags.toList(growable: true);
    _audience = short.audience;
    _allowComments = short.allowComments;
    _allowDownloads = short.allowDownloads;
    _sound = short.sound ?? ShortSound.original;
    _selectedAdId = short.ad?.id;
    _selectedAdTitle = short.ad?.title;
  }

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSeller =
        ref.watch(authControllerProvider).asAuthenticated?.seller.isSeller ??
        false;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: .9,
        minChildSize: .55,
        maxChildSize: .96,
        builder: (context, scrollController) => Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Edit Short', style: context.h5),
                        Text(
                          'Changes are reviewed again before they become visible.',
                          style: context.smallMuted,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close edit Short',
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                children: <Widget>[
                  TextField(
                    controller: _caption,
                    enabled: !_saving,
                    minLines: 4,
                    maxLines: 7,
                    maxLength: 1000,
                    decoration: const InputDecoration(
                      labelText: 'Caption',
                      hintText: 'Write a caption…',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _hashtagsEditor(),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    initialValue: _audience,
                    decoration: const InputDecoration(
                      labelText: 'Who can view',
                      border: OutlineInputBorder(),
                    ),
                    items: const <DropdownMenuItem<String>>[
                      DropdownMenuItem(
                        value: 'everyone',
                        child: Text('Everyone'),
                      ),
                      DropdownMenuItem(
                        value: 'followers',
                        child: Text('Followers'),
                      ),
                      DropdownMenuItem(
                        value: 'friends',
                        child: Text('Friends'),
                      ),
                      DropdownMenuItem(
                        value: 'only_me',
                        child: Text('Only you'),
                      ),
                    ],
                    onChanged: _saving
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() => _audience = value);
                            }
                          },
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: _allowComments,
                    title: const Text('Allow comments'),
                    subtitle: const Text('Let viewers comment.'),
                    onChanged: _saving
                        ? null
                        : (value) => setState(() => _allowComments = value),
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: _allowDownloads,
                    title: const Text('Allow downloads'),
                    subtitle: const Text('Let viewers save the video.'),
                    onChanged: _saving
                        ? null
                        : (value) => setState(() => _allowDownloads = value),
                  ),
                  const SizedBox(height: 8),
                  _soundEditor(),
                  if (isSeller) ...<Widget>[
                    const SizedBox(height: 20),
                    _productEditor(),
                  ],
                  if (_error != null) ...<Widget>[
                    const SizedBox(height: 16),
                    Semantics(
                      liveRegion: true,
                      child: Text(_error!, style: context.errorText),
                    ),
                  ],
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: _saving
                      ? const SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          'Save changes',
                          style: AppTextStylesX(context).button,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hashtagsEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: Text('Hashtags', style: context.pStrong)),
            Text('${_hashtags.length}/10', style: context.smallMuted),
          ],
        ),
        const SizedBox(height: 8),
        if (_hashtags.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _hashtags
                .map(
                  (tag) => InputChip(
                    label: Text('#$tag'),
                    onDeleted: _saving
                        ? null
                        : () => setState(() => _hashtags.remove(tag)),
                  ),
                )
                .toList(growable: false),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _saving || _hashtags.length >= 10 ? null : _addHashtag,
          icon: const Icon(Icons.tag_rounded),
          label: const Text('Add hashtag'),
        ),
      ],
    );
  }

  Widget _soundEditor() {
    final hasAddedSound = !_sound.isOriginal;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Sound', style: context.pStrong),
        const SizedBox(height: 8),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Theme.of(context).dividerColor),
          ),
          leading: Icon(
            hasAddedSound ? Icons.music_note_rounded : Icons.music_off_outlined,
          ),
          title: Text(_sound.title),
          subtitle: Text(
            hasAddedSound && _sound.artist.trim().isNotEmpty
                ? _sound.artist
                : 'Use the video audio',
          ),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: _saving ? null : _pickSound,
        ),
        if (hasAddedSound) ...<Widget>[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: <Widget>[
              OutlinedButton.icon(
                onPressed: _saving ? null : _editSoundControls,
                icon: const Icon(Icons.tune_rounded),
                label: const Text('Sound controls'),
              ),
              TextButton.icon(
                onPressed: _saving
                    ? null
                    : () => setState(() => _sound = ShortSound.original),
                icon: const Icon(Icons.music_off_outlined),
                label: const Text('Remove sound'),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _productEditor() {
    final hasProduct = _selectedAdId?.trim().isNotEmpty ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Tagged product', style: context.pStrong),
        const SizedBox(height: 4),
        Text(
          'Optional. Only your active products can be attached.',
          style: context.smallMuted,
        ),
        const SizedBox(height: 8),
        if (hasProduct)
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Theme.of(context).dividerColor),
            ),
            leading: const Icon(Icons.sell_outlined),
            title: Text(_selectedAdTitle ?? 'Tagged product'),
            subtitle: Text(_selectedAdId!),
            onTap: _saving ? null : _pickProduct,
            trailing: IconButton(
              tooltip: 'Remove product',
              onPressed: _saving
                  ? null
                  : () {
                      setState(() {
                        _selectedAdId = null;
                        _selectedAdTitle = null;
                        _adTouched = true;
                      });
                    },
              icon: const Icon(Icons.close_rounded),
            ),
          )
        else
          OutlinedButton.icon(
            onPressed: _saving ? null : _pickProduct,
            icon: const Icon(Icons.sell_outlined),
            label: const Text('Tag a product (optional)'),
          ),
      ],
    );
  }

  Future<void> _addHashtag() async {
    final controller = TextEditingController();
    final raw = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add hashtag'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (value) => Navigator.pop(context, value),
          decoration: const InputDecoration(prefixText: '# '),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text('Add', style: AppTextStylesX(context).button),
          ),
        ],
      ),
    );
    controller.dispose();
    final clean = _normalizeHashtag(raw ?? '');
    if (clean == null || _hashtags.contains(clean) || !mounted) return;
    setState(() => _hashtags.add(clean));
  }

  Future<void> _pickSound() async {
    final selected = await showMusicPickerSheet(context);
    if (selected == null || !mounted) return;
    if ((_selectedAdId?.trim().isNotEmpty ?? false) &&
        !selected.isCommercialSafe) {
      setState(() {
        _error = 'Product Shorts can only use commercial-safe sounds.';
      });
      return;
    }
    setState(() {
      _sound = selected;
      _error = null;
    });
  }

  Future<void> _editSoundControls() async {
    final result = await showShortSoundControlsSheet(
      context,
      sound: _sound,
      clipDuration: Duration(
        milliseconds: (short.durationSeconds * 1000).round(),
      ),
    );
    if (result != null && mounted) setState(() => _sound = result);
  }

  Future<void> _pickProduct() async {
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Material(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        clipBehavior: Clip.antiAlias,
        child: AdPickerBottomSheet(
          onSelected: (AOSAdListItem ad) {
            setState(() {
              _selectedAdId = ad.id;
              _selectedAdTitle = ad.title;
              _adTouched = true;
              if (!_sound.isOriginal && !_sound.isCommercialSafe) {
                _sound = ShortSound.original;
              }
              _error = null;
            });
          },
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_saving) return;
    final caption = _caption.text.trim();
    if (caption.length > 1000) return;
    setState(() {
      _saving = true;
      _error = null;
    });

    final initialSound = short.sound ?? ShortSound.original;
    final soundChanged = _sound != initialSound;
    final metadataChanged =
        caption != short.caption.toString() ||
        !_sameTags(_hashtags, short.hashtags) ||
        _audience != short.audience ||
        _allowComments != short.allowComments ||
        _allowDownloads != short.allowDownloads ||
        _adTouched;

    if (!metadataChanged && !soundChanged) {
      if (mounted) Navigator.pop(context, false);
      return;
    }

    final soundsApi = ref.read(shortsSoundsApiProvider);
    final removingSound = soundChanged && _sound.isOriginal;
    final changingToSound = soundChanged && !_sound.isOriginal;

    if (removingSound) {
      final removal = await soundsApi.removeShortSound(shortId: short.id.value);
      if (removal.isLeft) {
        if (mounted) {
          setState(() {
            _saving = false;
            _error = removal.leftOrNull!.message;
          });
        }
        return;
      }
    }

    if (metadataChanged) {
      final result = await ref
          .read(shortsUploadApiProvider)
          .updateMetadata(
            shortId: short.id.value,
            caption: caption,
            hashtags: _hashtags,
            audience: _audience,
            allowComments: _allowComments,
            allowDownloads: _allowDownloads,
            includeAdId: _adTouched,
            adId: _selectedAdId,
            soundId: changingToSound ? _sound.id : null,
            soundStartMs: _sound.startMs,
            soundDurationMs: _sound.durationMs,
            soundVolume: _sound.volume,
          );
      if (result.isLeft) {
        if (mounted) {
          setState(() {
            _saving = false;
            _error = removingSound
                ? 'Sound was removed, but the metadata update failed. ${result.leftOrNull!.message}'
                : result.leftOrNull!.message;
          });
        }
        return;
      }
    } else if (changingToSound) {
      final result = await soundsApi.changeShortSound(
        shortId: short.id.value,
        soundId: _sound.id,
        startMs: _sound.startMs,
        durationMs: _sound.durationMs,
        volume: _sound.volume,
      );
      if (result.isLeft) {
        if (mounted) {
          setState(() {
            _saving = false;
            _error = result.leftOrNull!.message;
          });
        }
        return;
      }
    }

    if (mounted) Navigator.pop(context, true);
  }

  String? _normalizeHashtag(String value) {
    final clean = value.trim().replaceFirst(RegExp('^#+'), '').toLowerCase();
    if (clean.isEmpty || clean.contains(RegExp(r'\s'))) return null;
    return clean;
  }

  bool _sameTags(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i += 1) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
