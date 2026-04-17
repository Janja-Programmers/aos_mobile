import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/features/notifications/application/providers/notification_providers.dart';
import 'package:africaonlinestores/features/notifications/application/services/in_app_notification_service.dart';
import 'package:africaonlinestores/shared/widgets/in_app_notification_banner.dart';

class InAppBannerListener extends ConsumerStatefulWidget {
  const InAppBannerListener({super.key});

  @override
  ConsumerState<InAppBannerListener> createState() =>
      _InAppBannerListenerState();
}

class _InAppBannerListenerState extends ConsumerState<InAppBannerListener> {
  StreamSubscription<InAppNotificationData?>? _sub;
  InAppNotificationData? _current;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final service = ref.read(inAppNotificationServiceProvider);

      _sub = service.stream.listen((data) {
        if (!mounted) return;
        setState(() {
          _current = data;
        });
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = _current;
    if (current == null) return const SizedBox.shrink();

    return InAppNotificationBanner(
      title: current.title,
      body: current.body,
      duration: current.duration,
      onTap: current.onTap,
      onDismiss: () {
        ref.read(inAppNotificationServiceProvider).markDismissed();
      },
    );
  }
}
