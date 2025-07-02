// lib/core/providers/base_provider.dart
import '/core/errors/failures.dart';
import 'package:flutter/foundation.dart';

mixin AsyncState<T> on ChangeNotifier {
  T? _data;
  T? get data => _data;

  Failure? _failure;
  Failure? get failure => _failure;

  bool _loading = false;
  bool get loading => _loading;

  DateTime? _lastFetched;
  DateTime? get lastFetched => _lastFetched;

  bool get hasError => _failure != null;
  bool get isEmpty => _data == null && !loading && !hasError;
  bool get isLoaded => _data != null && !loading;

  void setLoading() {
    _loading = true;
    _failure = null;
    notifyListeners();
  }

  void setSuccess(T newData) {
    _data = newData;
    _loading = false;
    _lastFetched = DateTime.now();
    notifyListeners();
  }

  void setFailure(Failure failure) {
    _failure = failure;
    _data = null;
    _loading = false;
    notifyListeners();
  }

  void clearState() {
    _data = null;
    _failure = null;
    _loading = false;
    _lastFetched = null;
    notifyListeners();
  }
}
