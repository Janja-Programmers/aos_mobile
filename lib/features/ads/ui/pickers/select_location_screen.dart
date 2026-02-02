import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:africaonlinestores/core/localization/locale_controller.dart';
import 'package:africaonlinestores/core/providers.dart';

class SelectLocationScreen extends ConsumerWidget {
  const SelectLocationScreen({super.key});

  String _idFrom(Map<String, dynamic> m) {
    return (m['id'] ?? m['name'] ?? m['code'] ?? '').toString();
  }

  String _labelFrom(Map<String, dynamic> m) {
    return (m['label'] ?? m['city'] ?? m['name'] ?? m['title'] ?? _idFrom(m))
        .toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref
        .watch(localeControllerProvider)
        .maybeWhen(data: (v) => v, orElse: () => null);
    final country = prefs?.countryCode ?? 'KE';

    return Scaffold(
      appBar: AppBar(title: const Text('Select Location')),
      body: FutureBuilder(
        future: ref.read(adsApiProvider).getLocations(countryCode: country),
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

          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final item = list[i];
              final id = _idFrom(item);
              final label = _labelFrom(item);
              return ListTile(
                title: Text(label),
                onTap: () =>
                    Navigator.of(context).pop({'id': id, 'label': label}),
              );
            },
          );
        },
      ),
    );
  }
}
