import 'package:africaonlinestores/features/catalog/domain/category_node.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CategoryNode', () {
    test('parses the current backend tree contract', () {
      final CategoryNode root = CategoryNode.fromJson(<String, dynamic>{
        'id': 'Vehicles',
        'name': 'Vehicles',
        'icon': 'https://cdn.example.invalid/vehicles.png',
        'icon_media': 'MEDIA-1',
        'icon_media_id': 'MEDIA-1',
        'parent_id': null,
        'sort_order': 10,
        'is_group': 1,
        'children': <Object?>[
          <String, dynamic>{
            'id': 'Cars',
            'name': 'Cars',
            'icon': '',
            'icon_media': null,
            'icon_media_id': null,
            'parent_id': 'Vehicles',
            'sort_order': 20,
            'is_group': 0,
            'children': <Object?>[],
          },
        ],
      });

      expect(root.id, 'Vehicles');
      expect(root.name, 'Vehicles');
      expect(root.isGroup, isTrue);
      expect(root.isSellable, isFalse);
      expect(root.iconMediaId, 'MEDIA-1');
      expect(root.parentId, isNull);
      expect(root.sortOrder, 10);
      expect(root.children.single.id, 'Cars');
      expect(root.children.single.isGroup, isFalse);
      expect(root.children.single.isSellable, isTrue);
      expect(root.children.single.icon, isNull);
    });

    test('uses icon_media when icon_media_id is absent', () {
      final CategoryNode node = CategoryNode.fromJson(<String, dynamic>{
        'id': 'Standalone',
        'name': 'Standalone',
        'icon': '',
        'icon_media': 'MEDIA-LEGACY',
        'parent_id': null,
        'sort_order': 0,
        'is_group': 0,
        'children': <Object?>[],
      });

      expect(node.iconMediaId, 'MEDIA-LEGACY');
      expect(node.isSellable, isTrue);
    });

    test('rejects a missing backend identifier', () {
      expect(
        () => CategoryNode.fromJson(<String, dynamic>{
          'name': 'Missing ID',
          'icon': '',
          'parent_id': null,
          'sort_order': 0,
          'is_group': 0,
          'children': <Object?>[],
        }),
        throwsFormatException,
      );
    });

    test('rejects a non-list children field', () {
      expect(
        () => CategoryNode.fromJson(<String, dynamic>{
          'id': 'Broken',
          'name': 'Broken',
          'icon': '',
          'parent_id': null,
          'sort_order': 0,
          'is_group': 0,
          'children': <String, dynamic>{},
        }),
        throwsFormatException,
      );
    });
  });
}
