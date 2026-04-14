import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:africaonlinestores/features/connect/chats/presentation/attachments/viewers/image_viewer.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/attachments/viewers/video_viewer.dart';

import 'package:africaonlinestores/shared/widgets/app_snack.dart';

class AttachmentOpener {
  static Future<void> open({
    required BuildContext context,
    required String type,
    required String url,
  }) async {
    switch (type) {
      case 'image':
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ImageViewer(url: url)),
        );
        break;

      case 'video':
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => VideoViewer(url: url)),
        );
        break;

      case 'audio':
        break;

      default:
        await _openExternal(context, url);
    }
  }

  // -----------------------------
  // EXTERNAL FILE HANDLER
  // -----------------------------
  static Future<void> _openExternal(BuildContext ctx, String url) async {
    final uri = Uri.parse(url);

    if (!await canLaunchUrl(uri)) {
      if (ctx.mounted) {
        ShowSnack(ctx, "Cannot open this type of document").warning();
      }
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
