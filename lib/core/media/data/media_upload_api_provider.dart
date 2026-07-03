import 'package:africaonlinestores/core/media/data/media_upload_api.dart';
import 'package:africaonlinestores/core/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<MediaUploadApi> mediaUploadApiProvider =
    Provider<MediaUploadApi>((ref) {
      return MediaUploadApi(ref.read(apiClientProvider));
    });
