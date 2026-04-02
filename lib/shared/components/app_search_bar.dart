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
    this.margin = const EdgeInsets.symmetric(vertical: 4),
  });

  final TextEditingController controller;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onMicTap;
  final VoidCallback? onCameraTap;
  final bool readOnly;
  final bool autofocus;
  final String hintText;
  final EdgeInsetsGeometry margin;

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
    final hasText = widget.controller.text.trim().isNotEmpty;

    return Padding(
      padding: widget.margin,
      child: Container(
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
                  ? Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: widget.onTap,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: double.infinity,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            hasText ? widget.controller.text : widget.hintText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: hasText
                                  ? colors.textPrimary
                                  : colors.textMuted,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
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
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        hintStyle: TextStyle(
                          color: colors.textMuted,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    ),
            ),

            if (!widget.readOnly && hasText)
              IconButton(
                splashRadius: 20,
                icon: Icon(Icons.close, color: colors.textMuted),
                onPressed: () {
                  widget.controller.clear();
                },
              ),

            if (widget.onMicTap != null)
              IconButton(
                splashRadius: 20,
                icon: Icon(Icons.mic, color: colors.textPrimary),
                onPressed: widget.onMicTap,
              ),

            if (widget.onCameraTap != null)
              IconButton(
                splashRadius: 20,
                icon: Icon(
                  Icons.camera_alt_outlined,
                  color: colors.textPrimary,
                ),
                onPressed: widget.onCameraTap,
              ),

            const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }
}
