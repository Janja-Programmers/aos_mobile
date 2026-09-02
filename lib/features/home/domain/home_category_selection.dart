import 'package:africaonlinestores/features/catalog/domain/category_node.dart';

const int _uint32Mask = 0xFFFFFFFF;
const int _fnvOffsetBasis = 0x811C9DC5;
const int _fnvPrime = 0x01000193;
const int _fallbackSeed = 0x6D2B79F5;

List<CategoryNode> selectHomeCategories(
  List<CategoryNode> categories, {
  required String seed,
  int limit = 4,
}) {
  if (categories.isEmpty || limit <= 0) {
    return const <CategoryNode>[];
  }

  final Map<String, CategoryNode> uniqueById = <String, CategoryNode>{};
  for (final CategoryNode category in categories) {
    final String id = category.id.trim();
    if (id.isEmpty) {
      continue;
    }
    uniqueById.putIfAbsent(id, () => category);
  }

  final List<CategoryNode> shuffled = List<CategoryNode>.of(uniqueById.values);
  if (shuffled.length <= 1) {
    return List<CategoryNode>.unmodifiable(shuffled.take(limit));
  }

  int state = _hashSeed(seed);
  if (state == 0) {
    state = _fallbackSeed;
  }

  for (int index = shuffled.length - 1; index > 0; index -= 1) {
    state = _nextState(state);
    final int swapIndex = state % (index + 1);
    final CategoryNode current = shuffled[index];
    shuffled[index] = shuffled[swapIndex];
    shuffled[swapIndex] = current;
  }

  final int resultLength = limit < shuffled.length ? limit : shuffled.length;
  return List<CategoryNode>.unmodifiable(shuffled.take(resultLength));
}

int _hashSeed(String value) {
  int hash = _fnvOffsetBasis;
  for (final int codeUnit in value.codeUnits) {
    hash ^= codeUnit;
    hash = (hash * _fnvPrime) & _uint32Mask;
  }
  return hash;
}

int _nextState(int state) {
  int value = state & _uint32Mask;
  value ^= (value << 13) & _uint32Mask;
  value ^= value >> 17;
  value ^= (value << 5) & _uint32Mask;
  return value & _uint32Mask;
}
