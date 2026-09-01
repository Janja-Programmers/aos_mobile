import 'dart:io';

enum MediaType { image, video }

class SelectedMedia {
  final File file;
  final MediaType type;

  /// Trusted local metadata measured from the prepared video before upload.
  ///
  /// The Shorts backend requires `duration_seconds` during media init. Keep the
  /// value with the selected media so the shared upload layer can forward the
  /// actual duration without re-measuring or fabricating it later.
  final double? durationSeconds;

  SelectedMedia(this.file, this.type, {this.durationSeconds});
}
