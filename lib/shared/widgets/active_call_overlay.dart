import 'package:africaonlinestores/features/connect/calls/navigation/call_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

import 'package:africaonlinestores/features/connect/calls/application/providers/call_providers.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_state.dart';
import 'package:africaonlinestores/features/connect/calls/application/state/call_status_enum.dart';

class ActiveCallOverlay extends ConsumerWidget {
  const ActiveCallOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callState = ref.watch(callManagerProvider);
    final manager = ref.read(callManagerProvider.notifier);
    final colors = context.appColors;

    if (callState.uiPhase != UiCallPhase.inCall &&
        callState.uiPhase != UiCallPhase.joiningRoom) {
      return const SizedBox.shrink();
    }

    final name = _displayName(callState);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
        color: colors.success,
        child: SafeArea(
          bottom: false,
          child: InkWell(
            onTap: () => CallNavigation.toActiveCall(ref),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  /// ⚪ white dot
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),

                  const SizedBox(width: 8),

                  /// 🧾 TEXT
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            color: colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "Tap to return to call",
                          style: TextStyle(color: colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  /// 🔴 END CALL
                  GestureDetector(
                    onTap: () async {
                      await manager.endCurrentCall();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.call_end, color: colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 🔤 SAME LOGIC AS ActiveCallScreen
  static String _displayName(CallState callState) {
    if (callState.direction == 'incoming') {
      return callState.caller?.displayName ??
          callState.caller?.userId ??
          'Incoming call';
    }

    return callState.receiver?.displayName ??
        callState.receiver?.userId ??
        callState.activeCall?.receiver?.displayName ??
        callState.activeCall?.receiver?.userId ??
        callState.activeCall?.caller?.displayName ??
        callState.activeCall?.caller?.userId ??
        'Calling...';
  }
}
