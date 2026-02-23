import 'package:equatable/equatable.dart';

class MarketContext extends Equatable {
  const MarketContext({
    required this.country,
    required this.displayCountryCode,
    this.locationId,
    this.locationLabel,
  });

  final String country; // "Kenya"
  final String displayCountryCode; // "KE"
  final String? locationId;
  final String? locationLabel;

  MarketContext copyWith({
    String? country,
    String? displayCountryCode,
    String? locationId,
    String? locationLabel,
  }) {
    return MarketContext(
      country: country ?? this.country,
      displayCountryCode: displayCountryCode ?? this.displayCountryCode,
      locationId: locationId ?? this.locationId,
      locationLabel: locationLabel ?? this.locationLabel,
    );
  }

  @override
  List<Object?> get props => [
    country,
    displayCountryCode,
    locationId,
    locationLabel,
  ];
}
