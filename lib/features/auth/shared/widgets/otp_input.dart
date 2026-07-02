import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

    widget.controller.focusAndHideKeyboard();
    if (mounted) setState(() {});
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
    const double gap = 4;
    const double height = 58;

    return LayoutBuilder(
      builder: (context, constraints) {
        final count = widget.controller.length;
        final available = constraints.maxWidth - (gap * (count - 1));
        final width = (available / count).clamp(46.0, 58.0);

        final scheme = Theme.of(context).colorScheme;
        final colors = context.appColors;

        final text = widget.controller.value;
        final caret = _caret;

        return Wrap(
          spacing: gap,
          alignment: WrapAlignment.spaceBetween,
          children: List.generate(count, (i) {
            final hasChar = i < text.length;
            final ch = hasChar ? text[i] : '';

            final focused =
                widget.enabled &&
                ((text.length < count && i == caret) ||
                    (text.length == count && i == count - 1));

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _tapBox(i),
              child: SizedBox(
                width: width,
                height: height,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: widget.enabled
                        ? scheme.surface
                        : scheme.surfaceContainerHighest.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: focused
                          ? scheme.primary
                          : colors.border.withValues(alpha: 0.6),
                      width: focused ? 2 : 1,
                    ),
                    boxShadow: focused
                        ? [
                            BoxShadow(
                              color: scheme.primary.withValues(alpha: 0.18),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Text(
                    ch.isEmpty ? '•' : ch,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: ch.isEmpty ? colors.textMuted : colors.textPrimary,
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
    return SizedBox.shrink(
      child: TextField(
        controller: widget.controller._textController,
        focusNode: widget.controller._focusNode,
        keyboardType: TextInputType.number,
        autofillHints: const [AutofillHints.oneTimeCode],
        readOnly: true,
        showCursor: false,
        cursorWidth: 0,
        enableInteractiveSelection: true,
        decoration: const InputDecoration(border: InputBorder.none),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onTap: widget.controller.focusAndHideKeyboard,
      ),
    );
  }

  Widget _keypad(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;
    const double keyGap = 12;

    void add(String d) {
      HapticFeedback.lightImpact();
      widget.controller.insertDigit(d);
      widget.controller.focusAndHideKeyboard();
    }

    Widget key(String label, {VoidCallback? onTap}) {
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: widget.enabled ? onTap : null,
          child: Ink(
            height: 56,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: widget.enabled ? colors.textPrimary : colors.textMuted,
                ),
              ),
            ),
          ),
        ),
      );
    }

    Widget iconKey(IconData icon, {VoidCallback? onTap}) {
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: widget.enabled ? onTap : null,
          child: Ink(
            height: 56,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 22,
                color: widget.enabled ? scheme.onSurface : colors.textMuted,
              ),
            ),
          ),
        ),
      );
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: widget.enabled ? 1 : 0.5,
      child: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              key('1', onTap: () => add('1')),
              const SizedBox(width: keyGap),
              key('2', onTap: () => add('2')),
              const SizedBox(width: keyGap),
              key('3', onTap: () => add('3')),
            ],
          ),
          const SizedBox(height: keyGap),
          Row(
            children: [
              key('4', onTap: () => add('4')),
              const SizedBox(width: keyGap),
              key('5', onTap: () => add('5')),
              const SizedBox(width: keyGap),
              key('6', onTap: () => add('6')),
            ],
          ),
          const SizedBox(height: keyGap),
          Row(
            children: [
              key('7', onTap: () => add('7')),
              const SizedBox(width: keyGap),
              key('8', onTap: () => add('8')),
              const SizedBox(width: keyGap),
              key('9', onTap: () => add('9')),
            ],
          ),
          const SizedBox(height: keyGap),
          Row(
            children: [
              iconKey(
                Icons.backspace_outlined,
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.controller.backspace();
                },
              ),

              const SizedBox(width: keyGap),
              key('0', onTap: () => add('0')),
              const SizedBox(width: keyGap),

              iconKey(
                Icons.clear,
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.controller.clear();
                },
              ),
            ],
          ),
        ],
      ),
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
