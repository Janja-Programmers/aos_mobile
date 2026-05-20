import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:africaonlinestores/core/routing/app_nav.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call.dart';
import 'package:africaonlinestores/shared/components/cards/section_card.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call_log.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call_participant.dart';
import 'package:africaonlinestores/features/connect/calls/application/providers/call_providers.dart';

void showCallDetailsSheet(BuildContext context, WidgetRef ref, CallLog call) {
  final colors = context.appColors;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),

    builder: (sheetContext) {
      return SafeArea(
        top: false, // 👈 important (keeps top rounded corners clean)
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// 🔝 TOP SECTION
              Column(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: colors.border,
                    child: Text(
                      call.displayName.isNotEmpty ? call.displayName[0] : "?",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    call.displayName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// 📋 DETAILS
              SectionCard(
                child: Column(
                  children: [
                    _row("Date", DateFormat.yMMMd().format(call.date)),
                    _row("Time", call.formattedTime),
                    _row("Duration", call.duration.toString()),
                    _row("Type", _type(call)),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// 🔘 ACTIONS
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(sheetContext);

                        await AppNavigation.requireAuth(
                          context,
                          ref,
                          onAuthenticated: () async {
                            await ref
                                .read(callStarterServiceProvider)
                                .startOutgoingCall(
                                  userId: call.user,
                                  callType: AOSCallType.audio,
                                  receiver: CallParticipant(
                                    userId: call.user,
                                    displayName:
                                        call.displayName.trim().isNotEmpty
                                        ? call.displayName.trim()
                                        : call.user,
                                    avatarUrl: call.avatar,
                                  ),
                                );
                          },
                        );
                      },
                      icon: Icon(Icons.call, color: context.appColors.white),
                      label: Text(
                        "Audio Call",
                        style: AppTextStylesX(context).button,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(sheetContext);

                        await AppNavigation.requireAuth(
                          context,
                          ref,
                          onAuthenticated: () async {
                            await ref
                                .read(callStarterServiceProvider)
                                .startOutgoingCall(
                                  userId: call.user,
                                  callType: AOSCallType.video,
                                  receiver: CallParticipant(
                                    userId: call.user,
                                    displayName:
                                        call.displayName.trim().isNotEmpty
                                        ? call.displayName.trim()
                                        : call.user,
                                    avatarUrl: call.avatar,
                                  ),
                                );
                          },
                        );
                      },
                      icon: Icon(
                        Icons.video_call,
                        color: context.appColors.white,
                      ),
                      label: Text(
                        "Video Call",
                        style: AppTextStylesX(context).button,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    },
  );
}

Widget _row(String left, String right) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(left, style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(right),
      ],
    ),
  );
}

String _type(CallLog call) {
  if (call.isMissed) return "Missed";
  return call.direction == "incoming" ? "Incoming" : "Outgoing";
}
