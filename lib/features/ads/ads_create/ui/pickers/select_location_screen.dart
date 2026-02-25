import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/core.dart';
import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/shared/components/app_search_bar.dart';
import 'package:africaonlinestores/shared/components/app_text_styles.dart';

class SelectLocationScreen extends ConsumerStatefulWidget {
  const SelectLocationScreen({super.key, this.selectedId});

  /// Pass current selected location id (null => All Cities selected)
  final String? selectedId;

  @override
  ConsumerState<SelectLocationScreen> createState() =>
      _SelectLocationScreenState();
}

class _SelectLocationScreenState extends ConsumerState<SelectLocationScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _idFrom(Map<String, dynamic> m) =>
      (m['id'] ?? m['name'] ?? m['code'] ?? '').toString();

  String _labelFrom(Map<String, dynamic> m) =>
      (m['label'] ?? m['city'] ?? m['name'] ?? m['title'] ?? _idFrom(m))
          .toString();

  bool _matches(String text, String q) =>
      q.isEmpty ? true : text.toLowerCase().contains(q.toLowerCase());

  @override
  Widget build(BuildContext context) {
    final q = _searchCtrl.text.trim();
    const accentRed = Color(0xFFDA1E28);

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location', style: context.h5),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: ref.read(adsApiProvider).getLocations(),
        builder: (context, snap) {
          if (!snap.hasData) {
            if (snap.hasError) {
              return Center(child: Text(snap.error.toString()));
            }
            return const Center(child: CircularProgressIndicator());
          }

          final res = snap.data!;
          if (res.isLeft) {
            return Center(child: Text(res.leftOrNull!.message));
          }

          final list = res.rightOrNull ?? const <Map<String, dynamic>>[];

          final filtered = list
              .where((m) => _matches(_labelFrom(m), q))
              .toList();

          // ✅ Only show All Cities when NOT searching
          final showAllCities = q.isEmpty;
          final foundCount = filtered.length + (showAllCities ? 1 : 0);

          final selectedId = (widget.selectedId ?? '').trim();
          final isAllSelected = selectedId.isEmpty;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // ✅ Reused AppSearchBar (no extra borders)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AppSearchBar(controller: _searchCtrl),
              ),

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('$foundCount locations found', style: context.p),
              ),

              const SizedBox(height: 6),

              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(top: 6),
                  itemCount: filtered.length + (showAllCities ? 1 : 0),
                  separatorBuilder: (_, _) {
                    return const SizedBox.shrink();
                  },
                  itemBuilder: (context, index) {
                    if (showAllCities && index == 0) {
                      return _LocationTile(
                        label: 'All Cities',
                        selected: isAllSelected,
                        accent: accentRed,
                        onTap: () => Navigator.of(
                          context,
                        ).pop({'id': '', 'label': 'All Cities'}),
                      );
                    }

                    final itemIndex = index - (showAllCities ? 1 : 0);
                    final item = filtered[itemIndex];
                    final id = _idFrom(item);
                    final label = _labelFrom(item);
                    final selected = !isAllSelected && id.trim() == selectedId;

                    return _LocationTile(
                      label: label,
                      selected: selected,
                      accent: accentRed,
                      onTap: () =>
                          Navigator.of(context).pop({'id': id, 'label': label}),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LocationTile extends StatelessWidget {
  const _LocationTile({
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return ListTile(
      onTap: onTap,
      leading: Icon(
        Icons.location_on_outlined,
        color: selected ? accent : colors.textPrimary,
      ),
      title: Text(label, style: context.pStrong),
      trailing: selected
          ? Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
              child: const Icon(Icons.check, size: 16, color: Colors.white),
            )
          : null,
    );
  }
}
