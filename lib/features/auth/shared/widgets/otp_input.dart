import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

class OtpInputController {
  OtpInputController({required this.length})
    : _textController = TextEditingController(),
      _focusNode = FocusNode();

  final int length;

  final TextEditingController _textController;
  final FocusNode _focusNode;

  String get value => _textController.text;

  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
  }

  void focusAndHideKeyboard() {
    _focusNode.requestFocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  void setSelection(int index) {
    final clamped = index.clamp(0, _textController.text.length);
    _textController.selection = TextSelection.collapsed(offset: clamped);
  }

  void setValue(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    final trimmed = digits.length > length
        ? digits.substring(0, length)
        : digits;
    _textController.value = TextEditingValue(
      text: trimmed,
      selection: TextSelection.collapsed(offset: trimmed.length),
    );
  }

  void insertDigit(String d) {
    final text = _textController.text;
    final sel = _textController.selection;

    final offset = sel.isValid ? sel.start : text.length;
    final caret = offset.clamp(0, text.length);

    if (text.length >= length) return;

    final next = text.substring(0, caret) + d + text.substring(caret);
    _textController.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(
        offset: (caret + 1).clamp(0, next.length),
      ),
    );
  }

  void backspace() {
    final text = _textController.text;
    final sel = _textController.selection;

    if (text.isEmpty) return;

    final offset = sel.isValid ? sel.start : text.length;
    final caret = offset.clamp(0, text.length);

    // Backspace deletes char before caret.
    if (caret == 0) return;

    final next = text.substring(0, caret - 1) + text.substring(caret);
    _textController.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(
        offset: (caret - 1).clamp(0, next.length),
      ),
    );
  }

  void clear() => setValue('');
}

class OtpInput extends StatefulWidget {
  const OtpInput({
    super.key,
    required this.controller,
    required this.enabled,
    required this.onChanged,
    required this.onCompleted,
    this.showCustomKeypad = true,
  });

  final OtpInputController controller;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onCompleted;

  final bool showCustomKeypad;

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  @override
  void initState() {
    super.initState();

    widget.controller._textController.addListener(_handleTextChanged);

    // Autofocus the hidden field, but keep keyboard hidden.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.controller.focusAndHideKeyboard();
    });
  }

  @override
  void didUpdateWidget(covariant OtpInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller._textController.removeListener(_handleTextChanged);
      widget.controller._textController.addListener(_handleTextChanged);
    }
  }

  @override
  void dispose() {
    widget.controller._textController.removeListener(_handleTextChanged);
    super.dispose();
  }

  void _handleTextChanged() {
    // Normalize to digits + max length
    final current = widget.controller._textController.text;
    final digits = current.replaceAll(RegExp(r'\D'), '');
    final trimmed = digits.length > widget.controller.length
        ? digits.substring(0, widget.controller.length)
        : digits;

    if (trimmed != current) {
      widget.controller.setValue(trimmed);
      return;
    }

    widget.onChanged(trimmed);

    if (trimmed.length == widget.controller.length) {
      widget.onCompleted(trimmed);
    }

    // Always keep keyboard hidden (custom keypad UX)
    widget.controller.focusAndHideKeyboard();
    if (mounted) setState(() {}); // update box highlight
  }

  int get _caret {
    final sel = widget.controller._textController.selection;
    if (!sel.isValid) return widget.controller.value.length;
    return sel.start.clamp(0, widget.controller.value.length);
  }

  void _tapBox(int index) {
    if (!widget.enabled) return;
    widget.controller.setSelection(index);
    widget.controller.focusAndHideKeyboard();
    setState(() {});
  }

  Widget _boxes(BuildContext context) {
    const double gap = 10;

    return LayoutBuilder(
      builder: (context, constraints) {
        final count = widget.controller.length;
        final available = constraints.maxWidth - (gap * (count - 1));
        final w = (available / count).clamp(44.0, 56.0);
        const h = 56.0;

        final scheme = Theme.of(context).colorScheme;
        final colors = context.appColors;

        final text = widget.controller.value;
        final caret = _caret;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          alignment: WrapAlignment.spaceBetween,
          children: List.generate(count, (i) {
            final hasChar = i < text.length;
            final ch = hasChar ? text[i] : '';

            // focused box = caret position OR last box when full
            final focused =
                widget.enabled &&
                ((text.length < count && i == caret) ||
                    (text.length == count && i == count - 1));

            return GestureDetector(
              onTap: () => _tapBox(i),
              child: SizedBox(
                width: w,
                height: h,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: focused ? scheme.primary : colors.stroke,
                      width: focused ? 1.5 : 1.0,
                    ),
                  ),
                  child: Text(
                    ch,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: colors.text,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _hiddenField() {
    return SizedBox(
      height: 0,
      width: 0,
      child: TextField(
        controller: widget.controller._textController,
        focusNode: widget.controller._focusNode,
        keyboardType: TextInputType.number,
        autofillHints: const [AutofillHints.oneTimeCode],
        readOnly: true,
        enableInteractiveSelection: true,
        showCursor: false,
        cursorWidth: 0,
        decoration: const InputDecoration(border: InputBorder.none),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],

        onTap: () {
          widget.controller.focusAndHideKeyboard();
        },
      ),
    );
  }

  Widget _keypad(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;

    Widget key(String label, {VoidCallback? onTap}) {
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.enabled ? onTap : null,
          child: Container(
            height: 52,
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: widget.enabled ? colors.text : colors.muted,
              ),
            ),
          ),
        ),
      );
    }

    Widget iconKey(IconData icon, {VoidCallback? onTap}) {
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.enabled ? onTap : null,
          child: Container(
            height: 52,
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: widget.enabled ? scheme.onSurface : colors.muted,
            ),
          ),
        ),
      );
    }

    void add(String d) {
      widget.controller.insertDigit(d);
      widget.controller.focusAndHideKeyboard();
    }

    return Column(
      children: [
        const SizedBox(height: 14),
        Row(
          children: [
            key('1', onTap: () => add('1')),
            key('2', onTap: () => add('2')),
            key('3', onTap: () => add('3')),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            key('4', onTap: () => add('4')),
            key('5', onTap: () => add('5')),
            key('6', onTap: () => add('6')),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            key('7', onTap: () => add('7')),
            key('8', onTap: () => add('8')),
            key('9', onTap: () => add('9')),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            iconKey(
              Icons.backspace_outlined,
              onTap: widget.controller.backspace,
            ),
            key('0', onTap: () => add('0')),
            iconKey(Icons.clear, onTap: widget.controller.clear),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _hiddenField(),
        _boxes(context),
        if (widget.showCustomKeypad) _keypad(context),
      ],
    );
  }
}
