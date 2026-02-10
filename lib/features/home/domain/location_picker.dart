class LocationPick {
  const LocationPick({required this.id, required this.label});

  final String? id;
  final String label;

  static LocationPick? fromPopResult(dynamic result) {
    if (result is Map) {
      final rawId = (result['id'] ?? '').toString().trim();
      final label = (result['label'] ?? '').toString().trim();
      if (label.isEmpty) return null;

      return LocationPick(id: rawId.isEmpty ? null : rawId, label: label);
    }
    return null;
  }
}
