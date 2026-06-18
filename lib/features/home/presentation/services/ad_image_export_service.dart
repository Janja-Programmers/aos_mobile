import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'package:africaonlinestores/core/api/api_client.dart';
import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/utils/logger.dart';

import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';

final adImageExportServiceProvider = Provider<AdImageExportService>((ref) {
  final apiClient = ref.watch(apiClientProvider);

  return AdImageExportService(apiClient);
});

class AdImageExportException implements Exception {
  const AdImageExportException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

class AdImageExportService {
  const AdImageExportService(this._apiClient);

  final ApiClient _apiClient;

  static const String _temporaryFilePrefix = 'aos_ad_export_';

  /// Files currently being prepared or shared by this app instance.
  ///
  /// Stale-file cleanup skips these paths so concurrent exports cannot delete
  /// one another's working files.
  static final Set<String> _activeExportPaths = <String>{};

  Future<ShareResult> exportImage({
    required String imageUrl,
    required Rect sharePositionOrigin,
  }) async {
    File? temporaryFile;

    try {
      await _cleanupAbandonedExports();

      final resolvedUrl = (buildFileUrl(imageUrl) ?? '').trim();

      if (resolvedUrl.isEmpty) {
        throw const AdImageExportException(
          'The image URL is empty or invalid.',
        );
      }

      final uri = Uri.tryParse(resolvedUrl);

      if (uri == null ||
          !uri.hasScheme ||
          (uri.scheme != 'http' && uri.scheme != 'https')) {
        throw AdImageExportException(
          'The image URL is not valid: $resolvedUrl',
        );
      }

      final extension = _resolveExtension(uri);
      final mimeType = _resolveMimeType(extension);

      temporaryFile = File(
        '${Directory.systemTemp.path}'
        '${Platform.pathSeparator}'
        '$_temporaryFilePrefix'
        '${DateTime.now().microsecondsSinceEpoch}'
        '$extension',
      );

      _activeExportPaths.add(temporaryFile.path);

      await _apiClient.dio.download(
        resolvedUrl,
        temporaryFile.path,
        deleteOnError: true,
        options: Options(
          followRedirects: true,
          receiveTimeout: const Duration(seconds: 45),
          sendTimeout: const Duration(seconds: 15),
          headers: const {'Accept': 'image/*,*/*;q=0.8'},
        ),
      );

      if (!await temporaryFile.exists()) {
        throw const AdImageExportException(
          'The image was downloaded, but the temporary file was not created.',
        );
      }

      final origin = _normalizeSharePositionOrigin(sharePositionOrigin);

      return await SharePlus.instance.share(
        ShareParams(
          title: 'Save or share image',
          files: [XFile(temporaryFile.path, mimeType: mimeType)],
          sharePositionOrigin: origin,
        ),
      );
    } on AdImageExportException {
      rethrow;
    } on DioException catch (error, stackTrace) {
      appLogger.e(
        'Ad image export download failed',
        error: error,
        stackTrace: stackTrace,
      );

      throw _mapDioException(error);
    } on MissingPluginException catch (error, stackTrace) {
      appLogger.e(
        'Share Plus plugin is not registered',
        error: error,
        stackTrace: stackTrace,
      );

      throw AdImageExportException(
        'The native share feature is unavailable. '
        'Stop the app completely and rebuild it.',
        cause: error,
      );
    } on PlatformException catch (error, stackTrace) {
      appLogger.e(
        'Native image export failed',
        error: error,
        stackTrace: stackTrace,
      );

      throw _mapPlatformException(error);
    } on FileSystemException catch (error, stackTrace) {
      appLogger.e(
        'Temporary image export file failed',
        error: error,
        stackTrace: stackTrace,
      );

      final osError = error.osError;

      final osDetail = osError == null
          ? ''
          : '${osError.message} (${osError.errorCode})';

      final detail = _compactMessage(
        osDetail.isNotEmpty ? osDetail : error.message,
      );

      throw AdImageExportException(
        detail.isEmpty
            ? 'The temporary image file could not be created.'
            : 'Temporary file error: $detail',
        cause: error,
      );
    } on FormatException catch (error, stackTrace) {
      appLogger.e(
        'Invalid image export URL',
        error: error,
        stackTrace: stackTrace,
      );

      final detail = _compactMessage(error.message);

      throw AdImageExportException(
        detail.isEmpty
            ? 'The image URL has an invalid format.'
            : 'Invalid image URL: $detail',
        cause: error,
      );
    } catch (error, stackTrace) {
      appLogger.e(
        'Unexpected ad image export failure',
        error: error,
        stackTrace: stackTrace,
      );

      final detail = _compactMessage(error);

      throw AdImageExportException(
        detail.isEmpty
            ? 'Unexpected image-export error '
                  '(${error.runtimeType}).'
            : 'Unexpected image-export error '
                  '(${error.runtimeType}): $detail',
        cause: error,
      );
    } finally {
      final file = temporaryFile;

      if (file != null) {
        _activeExportPaths.remove(file.path);
        await _deleteTemporaryFile(file);
      }
    }
  }

  /// Removes AOS export files left behind when the process was terminated
  /// before the normal finally block could run.
  ///
  /// This happens before the next export rather than retaining files for a
  /// fixed number of hours.
  Future<void> _cleanupAbandonedExports() async {
    final directory = Directory.systemTemp;

    try {
      if (!await directory.exists()) {
        return;
      }

      await for (final entity in directory.list(followLinks: false)) {
        if (entity is! File) {
          continue;
        }

        final filename = entity.uri.pathSegments.isEmpty
            ? ''
            : entity.uri.pathSegments.last;

        if (!filename.startsWith(_temporaryFilePrefix)) {
          continue;
        }

        if (_activeExportPaths.contains(entity.path)) {
          continue;
        }

        await _deleteTemporaryFile(entity);
      }
    } catch (error, stackTrace) {
      appLogger.w(
        'Unable to clean abandoned ad image exports',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  static Future<void> _deleteTemporaryFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (error, stackTrace) {
      appLogger.w(
        'Unable to delete temporary ad image export',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  static Rect _normalizeSharePositionOrigin(Rect origin) {
    if (origin.width > 0 &&
        origin.height > 0 &&
        origin.left.isFinite &&
        origin.top.isFinite &&
        origin.right.isFinite &&
        origin.bottom.isFinite) {
      return origin;
    }

    return const Rect.fromLTWH(0, 0, 1, 1);
  }

  static AdImageExportException _mapDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return AdImageExportException(
          'The connection timed out while contacting the image server.',
          cause: error,
        );

      case DioExceptionType.sendTimeout:
        return AdImageExportException(
          'The image request timed out before it could be sent.',
          cause: error,
        );

      case DioExceptionType.receiveTimeout:
        return AdImageExportException(
          'The image download timed out before it finished.',
          cause: error,
        );

      case DioExceptionType.badCertificate:
        return AdImageExportException(
          'The image server security certificate could not be verified.',
          cause: error,
        );

      case DioExceptionType.cancel:
        return AdImageExportException(
          'The image download was cancelled.',
          cause: error,
        );

      case DioExceptionType.connectionError:
        return AdImageExportException(
          'Could not connect to the image server. '
          'Check your internet connection and try again.',
          cause: error,
        );

      case DioExceptionType.badResponse:
        return _mapBadResponse(error);

      case DioExceptionType.unknown:
        final underlyingError = error.error;

        if (underlyingError is SocketException) {
          return AdImageExportException(
            'Could not reach the image server. '
            'Check your internet connection and try again.',
            cause: error,
          );
        }

        if (underlyingError is HandshakeException) {
          return AdImageExportException(
            'A secure connection to the image server could not be established.',
            cause: error,
          );
        }

        final detail = _compactMessage(underlyingError ?? error.message);

        return AdImageExportException(
          detail.isEmpty
              ? 'An unknown network error occurred while preparing the image.'
              : 'Image preparation error: $detail',
          cause: error,
        );
    }
  }

  static AdImageExportException _mapBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;

    if (statusCode == 401) {
      return AdImageExportException(
        'Your session has expired, or this image requires authentication.',
        cause: error,
      );
    }

    if (statusCode == 403) {
      return AdImageExportException(
        'You do not have permission to access this image.',
        cause: error,
      );
    }

    if (statusCode == 404) {
      return AdImageExportException(
        'The image could not be found on the server.',
        cause: error,
      );
    }

    if (statusCode == 408) {
      return AdImageExportException(
        'The image server timed out while processing the request.',
        cause: error,
      );
    }

    if (statusCode == 413) {
      return AdImageExportException(
        'The image is too large for the server to process.',
        cause: error,
      );
    }

    if (statusCode != null && statusCode >= 500) {
      return AdImageExportException(
        'The image server is temporarily unavailable '
        '(HTTP $statusCode).',
        cause: error,
      );
    }

    if (statusCode != null) {
      return AdImageExportException(
        'The image server rejected the request '
        '(HTTP $statusCode).',
        cause: error,
      );
    }

    return AdImageExportException(
      'The image server returned an invalid response.',
      cause: error,
    );
  }

  static AdImageExportException _mapPlatformException(PlatformException error) {
    final code = error.code.trim();

    final detail = _compactMessage(
      error.message ?? error.details ?? error.code,
    );

    final combined = '$code $detail'.toLowerCase();

    if (combined.contains('sharepositionorigin') ||
        combined.contains('popover')) {
      return AdImageExportException(
        'The native share sheet could not be positioned on this device.',
        cause: error,
      );
    }

    if (combined.contains('unavailable') ||
        combined.contains('not available') ||
        combined.contains('activity') ||
        combined.contains('viewcontroller')) {
      return AdImageExportException(
        'The native share sheet is unavailable on this device.',
        cause: error,
      );
    }

    if (combined.contains('file') &&
        (combined.contains('missing') ||
            combined.contains('not found') ||
            combined.contains('does not exist'))) {
      return AdImageExportException(
        'The prepared image file could not be shared.',
        cause: error,
      );
    }

    final codeLabel = code.isEmpty ? '' : ' [$code]';

    return AdImageExportException(
      detail.isEmpty
          ? 'Native share error$codeLabel.'
          : 'Native share error$codeLabel: $detail',
      cause: error,
    );
  }

  static String _resolveExtension(Uri uri) {
    final path = uri.path.toLowerCase();

    for (final extension in const [
      '.jpg',
      '.jpeg',
      '.png',
      '.webp',
      '.heic',
      '.heif',
      '.gif',
    ]) {
      if (path.endsWith(extension)) {
        return extension;
      }
    }

    return '.jpg';
  }

  static String _resolveMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpeg':
      case '.jpg':
        return 'image/jpeg';

      case '.png':
        return 'image/png';

      case '.webp':
        return 'image/webp';

      case '.heic':
        return 'image/heic';

      case '.heif':
        return 'image/heif';

      case '.gif':
        return 'image/gif';

      default:
        return 'image/jpeg';
    }
  }

  static String _compactMessage(Object? value) {
    final raw = value?.toString() ?? '';

    final compact = raw
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceFirst('Exception: ', '')
        .trim();

    if (compact.length <= 220) {
      return compact;
    }

    return '${compact.substring(0, 217)}...';
  }
}
