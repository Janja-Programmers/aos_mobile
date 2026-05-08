import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/features/preferences/controllers/user_preference_controller.dart';

class PriceAmountField extends ConsumerStatefulWidget {
  const PriceAmountField({
    super.key,
    required this.price,
    required this.onChanged,
    this.label = 'Price *',
  });

  final double? price;
  final ValueChanged<double?> onChanged;
  final String label;

  @override
  ConsumerState<PriceAmountField> createState() => _PriceAmountFieldState();
}

class _PriceAmountFieldState extends ConsumerState<PriceAmountField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.price?.toString() ?? '');
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  KeyboardActionsConfig _keyboardConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
      actions: [
        KeyboardActionsItem(
          focusNode: _focusNode,
          toolbarButtons: [
            (node) => TextButton(
              onPressed: node.unfocus,
              child: Text('Done', style: context.p),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(userPreferenceControllerProvider);
    final currency = prefs.currencyCode;

    return KeyboardActions(
      config: _keyboardConfig(context),
      disableScroll: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label, style: context.pStrong),
          const SizedBox(height: 8),
          TextFormField(
            controller: _controller,
            focusNode: _focusNode,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            style: context.p,
            decoration: InputDecoration(
              hintText: 'Enter price',
              hintStyle: context.pMuted,
              prefixIconConstraints: const BoxConstraints(minWidth: 0),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 12, right: 6),
                child: Text(currency, style: context.pStrong),
              ),
            ),
            onFieldSubmitted: (_) {
              _focusNode.unfocus();
            },
            onChanged: (v) {
              final n = double.tryParse(v.trim());
              widget.onChanged(n);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
