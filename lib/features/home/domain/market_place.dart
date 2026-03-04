import 'package:equatable/equatable.dart';

class MarketContext extends Equatable {
  const MarketContext({
    required this.country,
    required this.displayCountryCode,
    this.locationId,
    this.locationLabel,
    this.currency,
  });

  final String country;
  final String displayCountryCode;
  final String? locationId;
  final String? locationLabel;
  final String? currency;

  MarketContext copyWith({
    String? country,
    String? displayCountryCode,
    String? locationId,
    String? locationLabel,
    String? currency,
  }) {
    return MarketContext(
      country: country ?? this.country,
      displayCountryCode: displayCountryCode ?? this.displayCountryCode,
      locationId: locationId ?? this.locationId,
      locationLabel: locationLabel ?? this.locationLabel,
      currency: currency ?? this.currency,
    );
  }

  @override
  List<Object?> get props => [
    country,
    displayCountryCode,
    locationId,
    locationLabel,
    currency,
  ];
}
