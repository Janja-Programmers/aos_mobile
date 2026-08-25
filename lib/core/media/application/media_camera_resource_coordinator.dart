import 'package:africaonlinestores/core/media/domain/media_asset.dart';

class MediaCameraBusyException implements Exception {
  const MediaCameraBusyException(this.activeOwner);

  final MediaCameraOwner activeOwner;

  @override
  String toString() => 'Camera is already in use by ${activeOwner.name}.';
}

class MediaCameraLease {
  MediaCameraLease._(this._coordinator, this.owner, this._token);

  final MediaCameraResourceCoordinator _coordinator;
  final MediaCameraOwner owner;
  final Object _token;
  bool _released = false;

  bool get isReleased => _released;

  void release() {
    if (_released) return;
    _released = true;
    _coordinator._release(_token);
  }
}

class MediaCameraResourceCoordinator {
  MediaCameraLease? _activeLease;

  MediaCameraOwner? get activeOwner => _activeLease?.owner;

  MediaCameraLease acquire(MediaCameraOwner owner) {
    final active = _activeLease;
    if (active != null && !active.isReleased) {
      throw MediaCameraBusyException(active.owner);
    }

    // Lease identity must be unique; a const token would be canonicalized.
    // ignore: prefer_const_constructors
    final token = Object();
    final lease = MediaCameraLease._(this, owner, token);
    _activeLease = lease;
    return lease;
  }

  void _release(Object token) {
    final active = _activeLease;
    if (active == null || !identical(active._token, token)) return;
    _activeLease = null;
  }
}
