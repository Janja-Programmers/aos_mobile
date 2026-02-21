import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/shared/components/app_text_styles.dart';

class SelectOptionSheet extends StatefulWidget {
  const SelectOptionSheet({
    super.key,
    required this.title,
    required this.options,
    this.selected,
    this.multi = false,
  });

  final String title;
  final List<String> options;
  final dynamic selected;
  final bool multi;

  @override
  State<SelectOptionSheet> createState() => _SelectOptionSheetState();
}

class _SelectOptionSheetState extends State<SelectOptionSheet> {
  late Set<String> selectedSet;

  @override
  void initState() {
    super.initState();
    selectedSet = widget.multi
        ? {
            ...(widget.selected is List
                ? (widget.selected as List).map((e) => e.toString())
                : const <String>[]),
          }
        : {};
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),

                // Title
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(widget.title, style: context.h5),
                ),

                const SizedBox(height: 12),

                // Scrollable options
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    itemCount: widget.options.length,
                    separatorBuilder: (_, _) => const SizedBox.shrink(),
                    itemBuilder: (context, i) {
                      final opt = widget.options[i];

                      final isSel = widget.multi
                          ? selectedSet.contains(opt)
                          : widget.selected?.toString() == opt;

                      return ListTile(
                        title: Text(opt, style: context.p),
                        trailing: isSel
                            ? Icon(Icons.check, color: colors.primary)
                            : null,
                        onTap: () {
                          if (!widget.multi) {
                            Navigator.of(context).pop(opt);
                            return;
                          }

                          setState(() {
                            if (selectedSet.contains(opt)) {
                              selectedSet.remove(opt);
                            } else {
                              selectedSet.add(opt);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),

                if (widget.multi) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(selectedSet.toList());
                      },
                      child: Text('Apply', style: context.p),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
