import 'dart:io';

enum MediaType { image, video }

class SelectedMedia {
  final File file;
  final MediaType type;

  SelectedMedia(this.file, this.type);
}
