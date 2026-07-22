abstract interface class Clock {
  DateTime now();
}

class FixedClock implements Clock {
  FixedClock(this._value);

  final DateTime _value;

  @override
  DateTime now() => _value;
}

class MutableClock implements Clock {
  MutableClock(this._value);

  DateTime _value;

  @override
  DateTime now() => _value;

  void advance(Duration duration) {
    _value = _value.add(duration);
  }
}
