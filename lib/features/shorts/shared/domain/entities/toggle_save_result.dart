import 'package:equatable/equatable.dart';

class ToggleSaveResult extends Equatable {
  final String shortId;
  final bool saved;
  final int? saveCount;

  const ToggleSaveResult({
    required this.shortId,
    required this.saved,
    this.saveCount,
  });

  @override
  List<Object?> get props => [shortId, saved, saveCount];
}
