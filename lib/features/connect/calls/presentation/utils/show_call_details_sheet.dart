import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/shared/components/cards/section_card.dart';
import 'package:africaonlinestores/features/connect/calls/domain/call_log.dart';
import 'package:africaonlinestores/features/connect/calls/navigation/call_routes.dart';
import 'package:africaonlinestores/features/connect/chats/navigation/chat_routes.dart';

void showCallDetailsSheet(BuildContext context, WidgetRef ref, CallLog call) {
  final colors = context.appColors;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
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

                const SizedBox(height: 4),
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
                    onPressed: () {
                      Navigator.pop(context);
                      CallNavigation.toNewCall(ref);
                    },
                    icon: const Icon(Icons.call),
                    label: const Text("Call"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);

                      ChatNavigation.toNewMessage(context);
                    },
                    icon: const Icon(Icons.message),
                    label: const Text("Message"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
          ],
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
