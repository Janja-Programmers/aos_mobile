import 'package:flutter/material.dart';
import 'package:africaonlinestores/core/core.dart';

class AppSearchBar extends StatefulWidget {
  const AppSearchBar({
    super.key,
    required this.controller,
    this.onTap,
    this.onSubmitted,
    this.onMicTap,
    this.onCameraTap,
    this.readOnly = false,
    this.autofocus = false,
    this.hintText = "Search here...",
  });

  final TextEditingController controller;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onMicTap;
  final VoidCallback? onCameraTap;
  final bool readOnly;
  final bool autofocus;
  final String hintText;

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant AppSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(Icons.search, color: colors.textMuted),
          const SizedBox(width: 10),

          Expanded(
            child: widget.readOnly
                ? InkWell(
                    onTap: widget.onTap,
                    borderRadius: BorderRadius.circular(12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.controller.text.isEmpty
                            ? widget.hintText
                            : widget.controller.text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: widget.controller.text.isEmpty
                              ? colors.textMuted
                              : colors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  )
                : TextField(
                    controller: widget.controller,
                    autofocus: widget.autofocus,
                    readOnly: false,
                    onTap: widget.onTap,
                    onSubmitted: widget.onSubmitted,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: TextStyle(color: colors.textMuted),
                      border: InputBorder.none,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: context.appColors.surface,
                        ),
                      ),
                      isDense: true,
                    ),
                  ),
          ),

          if (!widget.readOnly && widget.controller.text.isNotEmpty)
            IconButton(
              icon: Icon(Icons.close, color: colors.textMuted),
              onPressed: widget.controller.clear,
            ),

          if (widget.onMicTap != null)
            IconButton(
              icon: Icon(Icons.mic, color: colors.textPrimary),
              onPressed: widget.onMicTap,
            ),

          if (widget.onCameraTap != null)
            IconButton(
              icon: Icon(Icons.camera_alt_outlined, color: colors.textPrimary),
              onPressed: widget.onCameraTap,
            ),

          const SizedBox(width: 6),
        ],
      ),
    );
  }
}
