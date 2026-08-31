enum MediaPickerOwner { photoLibrary, fileBrowser }

class MediaPickerBusyException implements Exception {
  const MediaPickerBusyException(this.activeOwner);

  final MediaPickerOwner activeOwner;

  @override
  String toString() =>
      'A media picker is already active for ${activeOwner.name}.';
}

class MediaPickerLease {
  MediaPickerLease._(this._coordinator, this.owner, this._token);

  final MediaPickerOperationCoordinator _coordinator;
  final MediaPickerOwner owner;
  final Object _token;
  bool _released = false;

  bool get isReleased => _released;

  void release() {
    if (_released) return;
    _released = true;
    _coordinator._release(_token);
  }
}

class MediaPickerOperationCoordinator {
  MediaPickerLease? _activeLease;

  MediaPickerOwner? get activeOwner => _activeLease?.owner;

  MediaPickerLease acquire(MediaPickerOwner owner) {
    final active = _activeLease;
    if (active != null && !active.isReleased) {
      throw MediaPickerBusyException(active.owner);
    }

    // Lease identity must be unique; a const token would be canonicalized.
    // ignore: prefer_const_constructors
    final token = Object();
    final lease = MediaPickerLease._(this, owner, token);
    _activeLease = lease;
    return lease;
  }

  void _release(Object token) {
    final active = _activeLease;
    if (active == null || !identical(active._token, token)) return;
    _activeLease = null;
  }
}
