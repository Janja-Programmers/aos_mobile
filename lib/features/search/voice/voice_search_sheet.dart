import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/search/controller/voice_input_controller.dart';
import 'package:africaonlinestores/features/search/voice/voice_listening_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VoiceSearchSheet extends ConsumerStatefulWidget {
  const VoiceSearchSheet({super.key});

  @override
  ConsumerState<VoiceSearchSheet> createState() => _VoiceSearchSheetState();
}

class _VoiceSearchSheetState extends ConsumerState<VoiceSearchSheet> {
  String _words = '';
  bool _closing = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;

      ref
          .read(voiceInputControllerProvider.notifier)
          .startListening(
            onWords: (words, {required bool isFinal}) {
              if (!mounted || _closing) return;

              setState(() => _words = words);

              // Do not auto-pop on iOS/final result.
              // Let the user explicitly tap Search.
            },
          );
    });
  }

  Future<void> _cancel() async {
    if (_closing) return;
    _closing = true;

    await ref.read(voiceInputControllerProvider.notifier).cancel();

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _search() async {
    if (_closing) return;

    final q = _words.trim();

    if (q.isEmpty) {
      await _cancel();
      return;
    }

    _closing = true;

    await ref.read(voiceInputControllerProvider.notifier).stopListening();

    if (!mounted) return;

    Navigator.of(context).pop(q);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final voice = ref.watch(voiceInputControllerProvider);

    final q = _words.trim();
    final canSearch = q.isNotEmpty && !_closing;

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

            const VoiceListeningIndicator(),

            const SizedBox(height: 20),

            Text(
              q.isEmpty ? voice.error ?? 'Listening...' : q,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: voice.error == null ? colors.textPrimary : colors.error,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _closing ? null : _cancel,
                    child: const Text('Cancel'),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: ElevatedButton(
                    onPressed: canSearch ? _search : null,
                    child: Text(
                      _closing ? 'Searching...' : 'Search',
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
