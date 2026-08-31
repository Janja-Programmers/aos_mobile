import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('display image constructors use bounded memory decoding', () {
    const Set<String> fullResolutionNetworkImages = <String>{
      'lib/features/connect/chats/presentation/attachments/viewers/'
          'image_viewer.dart',
    };
    const Set<String> fullResolutionFileImages = <String>{
      'lib/features/ads/ads_form/presentation/steps/widgets/edit_image/'
          'edit_image_screen.dart',
      'lib/features/ads/ads_form/presentation/steps/widgets/edit_image/widgets/'
          'background_removal_confirm_dialog.dart',
      'lib/features/ads/ads_form/presentation/steps/widgets/edit_image/widgets/'
          'preview_area.dart',
    };
    final List<String> violations = <String>[];

    for (final File file in _dartFiles()) {
      final String path = _normalizedPath(file);
      final String source = file.readAsStringSync();

      for (final String call in _calls(source, 'Image.network(')) {
        if (fullResolutionNetworkImages.contains(path)) continue;
        if (!_containsAny(call, const <String>[
          'cacheWidth:',
          'cacheHeight:',
        ])) {
          violations.add('$path has unbounded Image.network');
        }
      }

      for (final String call in _calls(source, 'Image.file(')) {
        if (fullResolutionFileImages.contains(path)) continue;
        if (!_containsAny(call, const <String>[
          'cacheWidth:',
          'cacheHeight:',
        ])) {
          violations.add('$path has unbounded Image.file');
        }
      }

      for (final String call in _calls(source, 'Image.memory(')) {
        if (!_containsAny(call, const <String>[
          'cacheWidth:',
          'cacheHeight:',
        ])) {
          violations.add('$path has unbounded Image.memory');
        }
      }

      for (final String call in _calls(source, 'CachedNetworkImage(')) {
        if (!call.contains('memCacheWidth:') ||
            !call.contains('memCacheHeight:')) {
          violations.add('$path has unbounded CachedNetworkImage');
        }
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('raw image providers stay behind approved decode-aware boundaries', () {
    const Set<String> rawNetworkProviderAllowlist = <String>{
      'lib/features/account/shared/utils/avator_image.dart',
      'lib/features/home/presentation/components/ad_details/'
          'image_header_section.dart',
      'lib/shared/images/app_image_decode.dart',
    };
    const Set<String> rawFileProviderAllowlist = <String>{
      'lib/shared/images/app_image_decode.dart',
    };
    final List<String> violations = <String>[];

    for (final File file in _dartFiles()) {
      final String path = _normalizedPath(file);
      final String source = file.readAsStringSync();

      if (_hasStandaloneCall(source, 'NetworkImage(') &&
          !rawNetworkProviderAllowlist.contains(path)) {
        violations.add('$path creates a raw NetworkImage');
      }
      if (_hasStandaloneCall(source, 'FileImage(') &&
          !rawFileProviderAllowlist.contains(path)) {
        violations.add('$path creates a raw FileImage');
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test(
    'avatar provider consumers immediately apply the shared decode policy',
    () {
      const Set<String> approvedConsumers = <String>{
        'lib/features/account/presentation/widgets/account_sections.dart',
        'lib/features/account/presentation/widgets/editable_avator.dart',
        'lib/features/home/presentation/components/ad_details/'
            'ad_seller_store_section.dart',
      };
      final List<String> violations = <String>[];

      for (final File file in _dartFiles()) {
        final String path = _normalizedPath(file);
        if (path == 'lib/features/account/shared/utils/avator_image.dart') {
          continue;
        }

        final String source = file.readAsStringSync();
        if (!source.contains('resolveAvatarImage(')) continue;

        if (!approvedConsumers.contains(path)) {
          violations.add('$path is an unreviewed resolveAvatarImage consumer');
        } else if (!source.contains('AppImageDecode.resizeProvider(')) {
          violations.add('$path consumes resolveAvatarImage without resizing');
        }
      }

      expect(violations, isEmpty, reason: violations.join('\n'));
    },
  );

  test('AppNetworkImage owns constraint and DPR-aware network decoding', () {
    final String source = File(
      'lib/shared/widgets/app_network_image.dart',
    ).readAsStringSync();

    expect(source, contains('LayoutBuilder('));
    expect(source, contains('AppImageDecode.forBox('));
    expect(source, contains('cacheWidth: decodeSize.width'));
    expect(source, contains('cacheHeight: decodeSize.height'));
  });
}

Iterable<File> _dartFiles() {
  return Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((File file) => file.path.endsWith('.dart'));
}

String _normalizedPath(File file) => file.path.replaceAll('\\', '/');

bool _containsAny(String source, List<String> needles) {
  return needles.any(source.contains);
}

bool _hasStandaloneCall(String source, String callName) {
  final RegExp pattern = RegExp('(?<![A-Za-z0-9_])${RegExp.escape(callName)}');
  return pattern.hasMatch(source);
}

Iterable<String> _calls(String source, String callName) sync* {
  final RegExp pattern = RegExp('(?<![A-Za-z0-9_])${RegExp.escape(callName)}');

  for (final RegExpMatch match in pattern.allMatches(source)) {
    final int openParen = source.indexOf('(', match.start);
    if (openParen < 0) continue;

    final int? closeParen = _matchingParen(source, openParen);
    if (closeParen == null) continue;

    yield source.substring(match.start, closeParen + 1);
  }
}

int? _matchingParen(String source, int openParen) {
  int depth = 0;
  String? quote;
  bool escaped = false;

  for (int index = openParen; index < source.length; index += 1) {
    final String character = source[index];

    if (quote != null) {
      if (escaped) {
        escaped = false;
        continue;
      }
      if (character == '\\') {
        escaped = true;
        continue;
      }
      if (character == quote) quote = null;
      continue;
    }

    if (character == "'" || character == '"') {
      quote = character;
      continue;
    }

    if (character == '(') {
      depth += 1;
    } else if (character == ')') {
      depth -= 1;
      if (depth == 0) return index;
    }
  }

  return null;
}
