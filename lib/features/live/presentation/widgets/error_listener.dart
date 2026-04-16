import 'package:africaonlinestores/features/live/application/providers/live_providers.dart';
import 'package:africaonlinestores/features/live/application/state/live_status_enum.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ErrorListener extends ConsumerWidget {
  final Widget child;

  const ErrorListener({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(liveManagerProvider, (prev, next) {
      if (prev?.status != LiveStatus.error &&
          next.status == LiveStatus.error &&
          next.errorMessage != null) {
        ShowSnack(context, next.errorMessage!).error();
      }
    });

    return child;
  }
}
