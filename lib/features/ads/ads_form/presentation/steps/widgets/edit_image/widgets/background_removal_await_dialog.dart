import 'dart:io';

import 'package:africaonlinestores/core/core.dart';
import 'package:flutter/material.dart';

class BackgroundRemovalAwaitDialog extends StatefulWidget {
  const BackgroundRemovalAwaitDialog({super.key, required this.removeBg});

  final Future<File> Function() removeBg;

  @override
  State<BackgroundRemovalAwaitDialog> createState() =>
      _BackgroundRemovalAwaitDialogState();
}

class _BackgroundRemovalAwaitDialogState
    extends State<BackgroundRemovalAwaitDialog> {
  String? _error;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      final file = await widget.removeBg();

      if (!mounted) return;

      Navigator.pop(context, file);
    } catch (e) {
      if (!mounted) return;

      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.appColors.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Background Removal',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              height: 275,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xffeeeeee),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: _error == null
                    ? const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(strokeWidth: 2.5),
                          SizedBox(height: 28),
                          Text(
                            'Processing on device...',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(_error!, textAlign: TextAlign.center),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
