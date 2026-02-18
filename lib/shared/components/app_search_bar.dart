import 'package:flutter/material.dart';
import 'package:africaonlinestores/core/core.dart';

class AppSearchBar extends StatefulWidget {
  const AppSearchBar({
    super.key,
    this.controller,
    this.onMicTap,
    this.onCameraTap,
    this.onSubmitted,
    this.readOnly = false,
    this.onTap,
    this.hintText = 'Search here...',
    this.textAlign = TextAlign.start,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final VoidCallback? onMicTap;
  final VoidCallback? onCameraTap;
  final ValueChanged<String>? onSubmitted;

  /// If true, user cannot type. Useful when tapping should open a new page.
  final bool readOnly;

  /// If provided, will run when the field is tapped.
  /// Common use: navigate to search screen.
  final VoidCallback? onTap;

  final String hintText;
  final TextAlign textAlign;
  final bool autofocus;

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  static const InputBorder _noBorder = InputBorder.none;

  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleTap() {
    // If caller wants navigation (or any custom behavior), let them handle it.
    if (widget.onTap != null) {
      widget.onTap!();

      // If it's readOnly, do not keep focus (avoids keyboard flashing).
      if (widget.readOnly) {
        _focusNode.unfocus();
      }
      return;
    }

    // Default behavior: if it's NOT readOnly, allow typing by requesting focus.
    if (!widget.readOnly) {
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;

    final borderColor = scheme.primary;
    final iconColor = colors.textMuted;

    final isFocused = _focusNode.hasFocus && !widget.readOnly;
    final outlineColor = isFocused ? borderColor : iconColor;

    return Material(
      color: Colors.transparent,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: outlineColor, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                readOnly: widget.readOnly,
                autofocus: widget.autofocus,
                onTap: _handleTap,
                textInputAction: TextInputAction.search,
                textAlign: widget.textAlign,
                onSubmitted: widget.onSubmitted,
                style: TextStyle(
                  fontSize: 15,
                  color: scheme.onSurface,
                  decoration: TextDecoration.none,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(fontSize: 15, color: iconColor),
                  prefixIcon: Icon(Icons.search, size: 20, color: iconColor),

                  border: _noBorder,
                  enabledBorder: _noBorder,
                  focusedBorder: _noBorder,
                  disabledBorder: _noBorder,
                  errorBorder: _noBorder,
                  focusedErrorBorder: _noBorder,

                  filled: false,
                  fillColor: Colors.transparent,

                  isDense: true,
                  isCollapsed: true,
                ),
              ),
            ),
            if (widget.onMicTap != null) ...[
              _TinyIconButton(
                icon: Icons.mic_none,
                color: iconColor,
                onTap: widget.onMicTap!,
              ),
            ],
            if (widget.onMicTap != null && widget.onCameraTap != null)
              const SizedBox(width: 8),
            if (widget.onCameraTap != null) ...[
              _TinyIconButton(
                icon: Icons.camera_alt_outlined,
                color: iconColor,
                onTap: widget.onCameraTap!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TinyIconButton extends StatelessWidget {
  const _TinyIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: SizedBox(
        width: 28,
        height: 28,
        child: Center(child: Icon(icon, size: 20, color: color)),
      ),
    );
  }
}
