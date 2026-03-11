import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/search/controller/voice_input_controller.dart';
import 'package:africaonlinestores/features/search/voice/voice_listening_indicator.dart';

class VoiceSearchSheet extends ConsumerStatefulWidget {
  const VoiceSearchSheet({super.key});

  @override
  ConsumerState<VoiceSearchSheet> createState() => _VoiceSearchSheetState();
}

class _VoiceSearchSheetState extends ConsumerState<VoiceSearchSheet> {
  String _words = '';

  @override
  void initState() {
    super.initState();

    /// Start listening immediately
    Future.microtask(() {
      ref
          .read(voiceInputControllerProvider.notifier)
          .toggleListening(
            onWords: (words, {required bool isFinal}) {
              if (!mounted) return;

              setState(() => _words = words);

              /// If speech finished automatically → return result
              if (isFinal && words.trim().isNotEmpty) {
                Navigator.pop(context, words.trim());
              }
            },
          );
    });
  }

  void _cancel() {
    ref.read(voiceInputControllerProvider.notifier).stopListening();
    Navigator.pop(context);
  }

  void _search() {
    ref.read(voiceInputControllerProvider.notifier).stopListening();

    if (_words.trim().isEmpty) {
      Navigator.pop(context);
      return;
    }

    Navigator.pop(context, _words.trim());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SafeArea(
      child: Container(
        color: colors.surface,
        padding: const EdgeInsets.all(20),
        height: 420,
        child: Column(
          children: [
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            /// Listening animation
            const VoiceListeningIndicator(),

            const SizedBox(height: 20),

            Text(
              _words.isEmpty ? "Listening..." : _words,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _cancel,
                    child: const Text("Cancel"),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: ElevatedButton(
                    onPressed: _search,
                    child: Text(
                      "Search",
                      style: context.p.copyWith(color: colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
