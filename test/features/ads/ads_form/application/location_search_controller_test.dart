import 'dart:async';

import 'package:africaonlinestores/core/api/failure.dart';
import 'package:africaonlinestores/core/utils/either.dart';
import 'package:africaonlinestores/features/ads/ads_form/application/location_search_controller.dart';
import 'package:africaonlinestores/features/ads/ads_form/domain/ad_location_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loads subsequent location pages without duplicates', () async {
    final repository = _FakeLocationRepository(<_RequestHandler>[
      ({
        required String? query,
        required int limit,
        required int offset,
      }) async {
        expect(query, isNull);
        expect(offset, 0);
        return Either.right(
          const AdLocationPage(
            items: <AdLocation>[
              AdLocation(
                id: 'LOC-1',
                name: 'Nairobi',
                country: 'KE',
                sortOrder: 1,
              ),
              AdLocation(
                id: 'LOC-2',
                name: 'Mombasa',
                country: 'KE',
                sortOrder: 2,
              ),
            ],
            limit: 20,
            offset: 0,
            hasMore: true,
            nextOffset: 20,
          ),
        );
      },
      ({
        required String? query,
        required int limit,
        required int offset,
      }) async {
        expect(query, isNull);
        expect(offset, 20);
        return Either.right(
          const AdLocationPage(
            items: <AdLocation>[
              AdLocation(
                id: 'LOC-2',
                name: 'Mombasa',
                country: 'KE',
                sortOrder: 2,
              ),
              AdLocation(
                id: 'LOC-3',
                name: 'Kisumu',
                country: 'KE',
                sortOrder: 3,
              ),
            ],
            limit: 20,
            offset: 20,
            hasMore: false,
            nextOffset: null,
          ),
        );
      },
    ]);
    final controller = LocationSearchController(repository);
    addTearDown(controller.dispose);

    await controller.loadInitial();
    await controller.loadMore();

    expect(controller.state.items.map((AdLocation item) => item.id), <String>[
      'LOC-1',
      'LOC-2',
      'LOC-3',
    ]);
    expect(controller.state.hasMore, isFalse);
    expect(repository.calls, 2);
  });

  test('repeated initial loads share one request for the same query', () async {
    final pending = Completer<Either<Failure, AdLocationPage>>();
    final repository = _FakeLocationRepository(<_RequestHandler>[
      ({required String? query, required int limit, required int offset}) {
        return pending.future;
      },
    ]);
    final controller = LocationSearchController(repository);
    addTearDown(controller.dispose);

    final first = controller.loadInitial();
    final second = controller.loadInitial();

    expect(repository.calls, 1);
    expect(identical(first, second), isTrue);

    pending.complete(
      Either.right(
        const AdLocationPage(
          items: <AdLocation>[],
          limit: 20,
          offset: 0,
          hasMore: false,
          nextOffset: null,
        ),
      ),
    );
    await Future.wait(<Future<void>>[first, second]);
  });

  test(
    'a newer query prevents a stale response from replacing results',
    () async {
      final first = Completer<Either<Failure, AdLocationPage>>();
      final second = Completer<Either<Failure, AdLocationPage>>();
      final repository = _FakeLocationRepository(<_RequestHandler>[
        ({required String? query, required int limit, required int offset}) {
          expect(query, isNull);
          return first.future;
        },
        ({required String? query, required int limit, required int offset}) {
          expect(query, 'Nairobi');
          return second.future;
        },
      ]);
      final controller = LocationSearchController(repository);
      addTearDown(controller.dispose);

      final oldRequest = controller.loadInitial();
      final newRequest = controller.search('Nairobi');

      second.complete(
        Either.right(
          const AdLocationPage(
            items: <AdLocation>[
              AdLocation(
                id: 'LOC-NBO',
                name: 'Nairobi',
                country: 'KE',
                sortOrder: 1,
              ),
            ],
            limit: 20,
            offset: 0,
            hasMore: false,
            nextOffset: null,
          ),
        ),
      );
      await newRequest;

      first.complete(
        Either.right(
          const AdLocationPage(
            items: <AdLocation>[
              AdLocation(
                id: 'LOC-OLD',
                name: 'Old result',
                country: 'KE',
                sortOrder: 1,
              ),
            ],
            limit: 20,
            offset: 0,
            hasMore: false,
            nextOffset: null,
          ),
        ),
      );
      await oldRequest;

      expect(controller.state.query, 'Nairobi');
      expect(controller.state.items.single.id, 'LOC-NBO');
    },
  );
}

typedef _RequestHandler =
    Future<Either<Failure, AdLocationPage>> Function({
      required String? query,
      required int limit,
      required int offset,
    });

class _FakeLocationRepository implements AdLocationRepository {
  _FakeLocationRepository(this._handlers);

  final List<_RequestHandler> _handlers;
  int calls = 0;

  @override
  Future<Either<Failure, AdLocationPage>> getLocations({
    String? query,
    int limit = 20,
    int offset = 0,
  }) {
    final handler = _handlers[calls++];
    return handler(query: query, limit: limit, offset: offset);
  }
}
