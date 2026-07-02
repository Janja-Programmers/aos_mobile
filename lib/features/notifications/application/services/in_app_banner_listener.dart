import 'dart:async';

import 'package:africaonlinestores/features/notifications/application/providers/notification_providers.dart';
import 'package:africaonlinestores/features/notifications/application/services/in_app_notification_service.dart';
import 'package:africaonlinestores/shared/widgets/in_app_notification_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InAppBannerListener extends ConsumerStatefulWidget {
  const InAppBannerListener({super.key});

  @override
  ConsumerState<InAppBannerListener> createState() =>
      _InAppBannerListenerState();
}

class _InAppBannerListenerState extends ConsumerState<InAppBannerListener> {
  late final InAppNotificationService _service;

  StreamSubscription<InAppNotificationData?>? _sub;
  InAppNotificationData? _current;

  @override
  void initState() {
    super.initState();

    _service = ref.read(inAppNotificationServiceProvider);

    _sub = _service.stream.listen((data) {
      if (!mounted) return;

      setState(() {
        _current = data;
      });
    });
  }

  @override
  void dispose() {
    unawaited(_sub?.cancel());
    _sub = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = _current;

    if (current == null) {
      return const SizedBox.shrink();
    }

    return InAppNotificationBanner(
      key: ValueKey(current.id),
      title: current.title,
      body: current.body,
      duration: current.duration,
      onTap: current.onTap,
      onDismiss: _service.markDismissed,
    );
  }
}
