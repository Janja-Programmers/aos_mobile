import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';

class ChatAttachmentSheet extends StatelessWidget {
  const ChatAttachmentSheet({
    super.key,
    required this.onGallery,
    required this.onCamera,
    required this.onVideoCall,
    required this.onAudioCall,
    required this.onDocument,
    required this.onLocation,
    required this.onContact,
  });

  final VoidCallback onGallery;
  final VoidCallback onCamera;
  final VoidCallback onVideoCall;
  final VoidCallback onAudioCall;
  final VoidCallback onDocument;
  final VoidCallback onLocation;
  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final items = <_AttachmentAction>[
      _AttachmentAction(
        icon: Icons.photo_library_outlined,
        label: l10n.chat_gallery,
        onTap: onGallery,
      ),
      _AttachmentAction(
        icon: Icons.photo_camera_outlined,
        label: l10n.chat_camera,
        onTap: onCamera,
      ),
      _AttachmentAction(
        icon: Icons.videocam_outlined,
        label: l10n.chat_video_call,
        onTap: onVideoCall,
      ),
      _AttachmentAction(
        icon: Icons.call_outlined,
        label: l10n.chat_voice_call,
        onTap: onAudioCall,
      ),
      _AttachmentAction(
        icon: Icons.location_on_outlined,
        label: l10n.chat_location,
        onTap: onLocation,
      ),
      _AttachmentAction(
        icon: Icons.insert_drive_file_outlined,
        label: l10n.chat_document,
        onTap: onDocument,
      ),
      _AttachmentAction(
        icon: Icons.person_outline_rounded,
        label: l10n.chat_contact,
        onTap: onContact,
      ),
    ];

    return SafeArea(
      top: false,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(top: BorderSide(color: colors.border)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 520 ? 5 : 4;
              const spacing = 12.0;
              final itemWidth =
                  (constraints.maxWidth - (columns - 1) * spacing) / columns;

              return Wrap(
                spacing: spacing,
                runSpacing: 20,
                children: items
                    .map(
                      (item) => SizedBox(
                        width: itemWidth,
                        child: _Item(action: item),
                      ),
                    )
                    .toList(growable: false),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AttachmentAction {
  const _AttachmentAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class _Item extends StatelessWidget {
  const _Item({required this.action});

  final _AttachmentAction action;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Semantics(
      button: true,
      label: action.label,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: action.onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 64),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.elevated,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(action.icon, size: 30, color: colors.textMuted),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              action.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.small.copyWith(color: colors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
