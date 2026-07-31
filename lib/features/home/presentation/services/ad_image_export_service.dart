// ignore_for_file: avoid_slow_async_io

import 'dart:io';

import 'package:africaonlinestores/core/providers.dart';
import 'package:africaonlinestores/core/utils/logger.dart';
import 'package:africaonlinestores/features/ads/shared/utils/file_url.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';

final adImageExportServiceProvider = Provider<AdImageExportService>((ref) {
  final apiClient = ref.watch(apiClientProvider);

  return AdImageExportService(
    apiClient.dio,
    galleryWriter: const GalAdGalleryWriter(),
  );
});

class AdImageExportException implements Exception {
  const AdImageExportException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

enum AdGalleryMediaType { image, video }

abstract interface class AdGalleryWriter {
  Future<bool> hasAccess();

  Future<bool> requestAccess();

  Future<void> save({
    required String filePath,
    required AdGalleryMediaType mediaType,
  });
}

final class GalAdGalleryWriter implements AdGalleryWriter {
  const GalAdGalleryWriter();

  @override
  Future<bool> hasAccess() => Gal.hasAccess();

  @override
  Future<bool> requestAccess() => Gal.requestAccess();

  @override
  Future<void> save({
    required String filePath,
    required AdGalleryMediaType mediaType,
  }) {
    return switch (mediaType) {
      AdGalleryMediaType.image => Gal.putImage(filePath),
      AdGalleryMediaType.video => Gal.putVideo(filePath),
    };
  }
}

class AdImageExportService {
  const AdImageExportService(
    this._dio, {
    required AdGalleryWriter galleryWriter,
  }) : _galleryWriter = galleryWriter;

  final Dio _dio;
  final AdGalleryWriter _galleryWriter;

  static const String _temporaryFilePrefix = 'aos_ad_gallery_';

  /// Files currently being downloaded or saved by this app instance.
  ///
  /// Stale-file cleanup skips these paths so concurrent downloads cannot delete
  /// one another's working files.
  static final Set<String> _activeExportPaths = <String>{};

  Future<void> saveImageToGallery({required String imageUrl}) {
    return _saveMediaToGallery(
      mediaUrl: imageUrl,
      mediaType: AdGalleryMediaType.image,
    );
  }

  Future<void> saveVideoToGallery({required String videoUrl}) {
    return _saveMediaToGallery(
      mediaUrl: videoUrl,
      mediaType: AdGalleryMediaType.video,
    );
  }

  Future<void> _saveMediaToGallery({
    required String mediaUrl,
    required AdGalleryMediaType mediaType,
  }) async {
    File? temporaryFile;

    try {
      await _cleanupAbandonedExports();

      final resolvedUrl = (buildFileUrl(mediaUrl) ?? '').trim();

      if (resolvedUrl.isEmpty) {
        throw AdImageExportException(
          'The ${mediaType.name} URL is empty or invalid.',
        );
      }

      final uri = Uri.tryParse(resolvedUrl);

      if (uri == null ||
          !uri.hasScheme ||
          (uri.scheme != 'http' && uri.scheme != 'https')) {
        throw AdImageExportException(
          'The ${mediaType.name} URL is not valid: $resolvedUrl',
        );
      }

      final hasAccess = await _galleryWriter.hasAccess();
      final accessGranted = hasAccess || await _galleryWriter.requestAccess();

      if (!accessGranted) {
        throw const AdImageExportException(
          'Gallery access was denied. Allow photo access in device settings '
          'and try again.',
        );
      }

      final extension = _resolveExtension(uri, mediaType);

      temporaryFile = File(
        '${Directory.systemTemp.path}'
        '${Platform.pathSeparator}'
        '$_temporaryFilePrefix'
        '${DateTime.now().microsecondsSinceEpoch}'
        '$extension',
      );

      _activeExportPaths.add(temporaryFile.path);

      final acceptHeader = switch (mediaType) {
        AdGalleryMediaType.image => 'image/*,*/*;q=0.8',
        AdGalleryMediaType.video => 'video/*,*/*;q=0.8',
      };

      await _dio.download(
        resolvedUrl,
        temporaryFile.path,
        options: Options(
          followRedirects: true,
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 15),
          headers: <String, String>{'Accept': acceptHeader},
        ),
      );

      final fileExists = await temporaryFile.exists();
      final fileLength = fileExists ? await temporaryFile.length() : 0;

      if (!fileExists || fileLength == 0) {
        throw AdImageExportException(
          'The ${mediaType.name} was downloaded, but the temporary file is '
          'missing or empty.',
        );
      }

      await _galleryWriter.save(
        filePath: temporaryFile.path,
        mediaType: mediaType,
      );
    } on AdImageExportException {
      rethrow;
    } on GalException catch (error, stackTrace) {
      appLogger.e(
        'Native ad media gallery save failed',
        error: error,
        stackTrace: stackTrace,
      );

      throw _mapGalException(error);
    } on DioException catch (error, stackTrace) {
      appLogger.e(
        'Ad media gallery download failed',
        error: error,
        stackTrace: stackTrace,
      );

      throw _mapDioException(error);
    } on MissingPluginException catch (error, stackTrace) {
      appLogger.e(
        'Gallery plugin is not registered',
        error: error,
        stackTrace: stackTrace,
      );

      throw AdImageExportException(
        'The native gallery feature is unavailable. '
        'Stop the app completely and rebuild it.',
        cause: error,
      );
    } on PlatformException catch (error, stackTrace) {
      appLogger.e(
        'Native gallery save failed',
        error: error,
        stackTrace: stackTrace,
      );

      throw _mapPlatformException(error);
    } on FileSystemException catch (error, stackTrace) {
      appLogger.e(
        'Temporary ad media file failed',
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
            ? 'The temporary media file could not be created.'
            : 'Temporary file error: $detail',
        cause: error,
      );
    } on FormatException catch (error, stackTrace) {
      appLogger.e('Invalid ad media URL', error: error, stackTrace: stackTrace);

      final detail = _compactMessage(error.message);

      throw AdImageExportException(
        detail.isEmpty
            ? 'The media URL has an invalid format.'
            : 'Invalid media URL: $detail',
        cause: error,
      );
    } catch (error, stackTrace) {
      appLogger.e(
        'Unexpected ad media gallery-save failure',
        error: error,
        stackTrace: stackTrace,
      );

      final detail = _compactMessage(error);

      throw AdImageExportException(
        detail.isEmpty
            ? 'Unexpected media-download error (${error.runtimeType}).'
            : 'Unexpected media-download error '
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

  /// Removes AOS gallery-download files left behind when the process was terminated
  /// before the normal finally block could run.
  ///
  /// This happens before the next download rather than retaining files for a
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
        'Unable to clean abandoned ad gallery downloads',
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
        'Unable to delete temporary ad gallery download',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  static AdImageExportException _mapDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return AdImageExportException(
          'The connection timed out while contacting the media server.',
          cause: error,
        );

      case DioExceptionType.sendTimeout:
        return AdImageExportException(
          'The media request timed out before it could be sent.',
          cause: error,
        );

      case DioExceptionType.receiveTimeout:
        return AdImageExportException(
          'The media download timed out before it finished.',
          cause: error,
        );

      case DioExceptionType.badCertificate:
        return AdImageExportException(
          'The media server security certificate could not be verified.',
          cause: error,
        );

      case DioExceptionType.cancel:
        return AdImageExportException(
          'The media download was cancelled.',
          cause: error,
        );

      case DioExceptionType.connectionError:
        return AdImageExportException(
          'Could not connect to the media server. '
          'Check your internet connection and try again.',
          cause: error,
        );

      case DioExceptionType.badResponse:
        return _mapBadResponse(error);

      case DioExceptionType.unknown:
        final underlyingError = error.error;

        if (underlyingError is SocketException) {
          return AdImageExportException(
            'Could not reach the media server. '
            'Check your internet connection and try again.',
            cause: error,
          );
        }

        if (underlyingError is HandshakeException) {
          return AdImageExportException(
            'A secure connection to the media server could not be established.',
            cause: error,
          );
        }

        final detail = _compactMessage(underlyingError ?? error.message);

        return AdImageExportException(
          detail.isEmpty
              ? 'An unknown network error occurred while preparing the media.'
              : 'Media preparation error: $detail',
          cause: error,
        );
    }
  }

  static AdImageExportException _mapBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;

    if (statusCode == 401) {
      return AdImageExportException(
        'Your session has expired, or this media requires authentication.',
        cause: error,
      );
    }

    if (statusCode == 403) {
      return AdImageExportException(
        'You do not have permission to access this media.',
        cause: error,
      );
    }

    if (statusCode == 404) {
      return AdImageExportException(
        'The media could not be found on the server.',
        cause: error,
      );
    }

    if (statusCode == 408) {
      return AdImageExportException(
        'The media server timed out while processing the request.',
        cause: error,
      );
    }

    if (statusCode == 413) {
      return AdImageExportException(
        'The media is too large for the server to process.',
        cause: error,
      );
    }

    if (statusCode != null && statusCode >= 500) {
      return AdImageExportException(
        'The media server is temporarily unavailable '
        '(HTTP $statusCode).',
        cause: error,
      );
    }

    if (statusCode != null) {
      return AdImageExportException(
        'The media server rejected the request '
        '(HTTP $statusCode).',
        cause: error,
      );
    }

    return AdImageExportException(
      'The media server returned an invalid response.',
      cause: error,
    );
  }

  static AdImageExportException _mapGalException(GalException error) {
    return switch (error.type) {
      GalExceptionType.accessDenied => AdImageExportException(
        'Gallery access was denied. Allow photo access in device settings '
        'and try again.',
        cause: error,
      ),
      GalExceptionType.notEnoughSpace => AdImageExportException(
        'There is not enough storage space to save this media.',
        cause: error,
      ),
      GalExceptionType.notSupportedFormat => AdImageExportException(
        'This media format is not supported by the device gallery.',
        cause: error,
      ),
      GalExceptionType.unexpected => AdImageExportException(
        'The device gallery could not save this media.',
        cause: error,
      ),
    };
  }

  static AdImageExportException _mapPlatformException(PlatformException error) {
    final code = error.code.trim();
    final detail = _compactMessage(
      error.message ?? error.details ?? error.code,
    );
    final combined = '$code $detail'.toLowerCase();

    if (combined.contains('permission') ||
        combined.contains('denied') ||
        combined.contains('access')) {
      return AdImageExportException(
        'Gallery access was denied. Allow photo access in device settings '
        'and try again.',
        cause: error,
      );
    }

    if (combined.contains('space') || combined.contains('storage full')) {
      return AdImageExportException(
        'There is not enough storage space to save this media.',
        cause: error,
      );
    }

    if (combined.contains('format') || combined.contains('unsupported')) {
      return AdImageExportException(
        'This media format is not supported by the device gallery.',
        cause: error,
      );
    }

    if (combined.contains('unavailable') ||
        combined.contains('not available') ||
        combined.contains('activity') ||
        combined.contains('viewcontroller')) {
      return AdImageExportException(
        'The native gallery is unavailable on this device.',
        cause: error,
      );
    }

    final codeLabel = code.isEmpty ? '' : ' [$code]';

    return AdImageExportException(
      detail.isEmpty
          ? 'Native gallery error$codeLabel.'
          : 'Native gallery error$codeLabel: $detail',
      cause: error,
    );
  }

  static String _resolveExtension(Uri uri, AdGalleryMediaType mediaType) {
    final path = uri.path.toLowerCase();
    final supportedExtensions = switch (mediaType) {
      AdGalleryMediaType.image => const <String>[
        '.jpg',
        '.jpeg',
        '.png',
        '.webp',
        '.heic',
        '.heif',
        '.gif',
      ],
      AdGalleryMediaType.video => const <String>[
        '.mp4',
        '.mov',
        '.m4v',
        '.webm',
        '.3gp',
      ],
    };

    for (final extension in supportedExtensions) {
      if (path.endsWith(extension)) {
        return extension;
      }
    }

    return switch (mediaType) {
      AdGalleryMediaType.image => '.jpg',
      AdGalleryMediaType.video => '.mp4',
    };
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
