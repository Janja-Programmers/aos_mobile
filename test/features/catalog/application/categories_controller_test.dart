import 'dart:async';
import 'dart:collection';

import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/features/catalog/domain/categories_repository.dart';
import 'package:africaonlinestores/features/catalog/domain/category_node.dart';
import 'package:africaonlinestores/features/catalog/shared/providers/categories_controller.dart';
import 'package:africaonlinestores/features/catalog/shared/providers/category_ads_provider.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/provider_container.dart';

void main() {
  test('loads categories and selects the first backend root', () async {
    final ScriptedCategoriesRepository repository =
        ScriptedCategoriesRepository()
          ..enqueueValue(<CategoryNode>[_root('A'), _root('B')]);
    final container = createTestContainer(
      overrides: <Override>[
        categoriesRepositoryProvider.overrideWithValue(repository),
      ],
    );

    container.read(categoriesControllerProvider);
    await _waitUntil(
      () => !container.read(categoriesControllerProvider).loading,
    );

    final state = container.read(categoriesControllerProvider);
    expect(state.parents.map((CategoryNode node) => node.id), <String>[
      'A',
      'B',
    ]);
    expect(state.selectedParentId, 'A');
    expect(state.errorMessage, isNull);
  });

  test('shows an error and recovers through reload', () async {
    final ScriptedCategoriesRepository repository =
        ScriptedCategoriesRepository()
          ..enqueue(
            Either<Failure, List<CategoryNode>>.left(
              const Failure('Catalog unavailable.'),
            ),
          )
          ..enqueueValue(<CategoryNode>[_root('Recovered')]);
    final container = createTestContainer(
      overrides: <Override>[
        categoriesRepositoryProvider.overrideWithValue(repository),
      ],
    );

    container.read(categoriesControllerProvider);
    await _waitUntil(
      () => !container.read(categoriesControllerProvider).loading,
    );
    expect(
      container.read(categoriesControllerProvider).errorMessage,
      'Catalog unavailable.',
    );

    await container.read(categoriesControllerProvider.notifier).reload();

    final state = container.read(categoriesControllerProvider);
    expect(state.errorMessage, isNull);
    expect(state.parents.single.id, 'Recovered');
  });

  test('preserves a valid selection and clears a removed one', () async {
    final ScriptedCategoriesRepository repository =
        ScriptedCategoriesRepository()
          ..enqueueValue(<CategoryNode>[_root('A'), _root('B')])
          ..enqueueValue(<CategoryNode>[_root('B'), _root('C')])
          ..enqueueValue(<CategoryNode>[_root('C')]);
    final container = createTestContainer(
      overrides: <Override>[
        categoriesRepositoryProvider.overrideWithValue(repository),
      ],
    );

    container.read(categoriesControllerProvider);
    await _waitUntil(
      () => !container.read(categoriesControllerProvider).loading,
    );
    final controller = container.read(categoriesControllerProvider.notifier);
    controller.selectParent('B');

    await controller.reload();
    expect(container.read(categoriesControllerProvider).selectedParentId, 'B');

    await controller.reload();
    expect(container.read(categoriesControllerProvider).selectedParentId, 'C');
  });

  test('an older request cannot overwrite a newer reload', () async {
    final Completer<Either<Failure, List<CategoryNode>>> older =
        Completer<Either<Failure, List<CategoryNode>>>();
    final Completer<Either<Failure, List<CategoryNode>>> newer =
        Completer<Either<Failure, List<CategoryNode>>>();
    final ScriptedCategoriesRepository repository =
        ScriptedCategoriesRepository()
          ..enqueueFuture(older.future)
          ..enqueueFuture(newer.future);
    final container = createTestContainer(
      overrides: <Override>[
        categoriesRepositoryProvider.overrideWithValue(repository),
      ],
    );

    container.read(categoriesControllerProvider);
    final reload = container
        .read(categoriesControllerProvider.notifier)
        .reload();
    newer.complete(
      Either<Failure, List<CategoryNode>>.right(<CategoryNode>[_root('New')]),
    );
    await reload;
    older.complete(
      Either<Failure, List<CategoryNode>>.right(<CategoryNode>[_root('Old')]),
    );
    await older.future;
    await Future<void>.delayed(Duration.zero);

    expect(
      container.read(categoriesControllerProvider).parents.single.id,
      'New',
    );
  });
}

CategoryNode _root(String id) {
  return CategoryNode(id: id, name: id, isGroup: true);
}

Future<void> _waitUntil(bool Function() condition) async {
  for (var attempt = 0; attempt < 100; attempt += 1) {
    if (condition()) {
      return;
    }
    await Future<void>.delayed(Duration.zero);
  }
  throw StateError('Timed out waiting for controller state.');
}

class ScriptedCategoriesRepository implements CategoriesRepository {
  final Queue<Future<Either<Failure, List<CategoryNode>>>> _responses =
      Queue<Future<Either<Failure, List<CategoryNode>>>>();

  void enqueue(Either<Failure, List<CategoryNode>> value) {
    enqueueFuture(Future<Either<Failure, List<CategoryNode>>>.value(value));
  }

  void enqueueValue(List<CategoryNode> value) {
    enqueue(Either<Failure, List<CategoryNode>>.right(value));
  }

  void enqueueFuture(Future<Either<Failure, List<CategoryNode>>> value) {
    _responses.add(value);
  }

  @override
  Future<Either<Failure, List<CategoryNode>>> getCategories() {
    if (_responses.isEmpty) {
      throw StateError('No scripted category response remains.');
    }
    return _responses.removeFirst();
  }
}
