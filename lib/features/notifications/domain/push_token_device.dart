enum PushDeviceType { android, ios, web }

extension PushDeviceTypeX on PushDeviceType {
  String get value {
    switch (this) {
      case PushDeviceType.android:
        return 'android';
      case PushDeviceType.ios:
        return 'ios';
      case PushDeviceType.web:
        return 'web';
    }
  }
}

class PushTokenDevice {
  final String token;
  final PushDeviceType deviceType;
  final String? deviceId;

  const PushTokenDevice({
    required this.token,
    required this.deviceType,
    this.deviceId,
  });

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'device_type': deviceType.value,
      'device_id': deviceId,
    };
  }
}
