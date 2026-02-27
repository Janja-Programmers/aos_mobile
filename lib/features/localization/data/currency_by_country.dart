// core/localization/currency_by_country.dart
const Map<String, String> currencyByCountry = {
  "KE": "KES",
  "UG": "UGX",
  "TZ": "TZS",
  "RW": "RWF",
  "BI": "BIF",
  "ET": "ETB",
  "NG": "NGN",
  "GH": "GHS",
  "ZA": "ZAR",
  "EG": "EGP",
  "MA": "MAD",
  "DZ": "DZD",
  "SN": "XOF",
  "CI": "XOF",
  "CM": "XAF",
  "GA": "XAF",
  "CD": "CDF",
  "ZM": "ZMW",
  "MW": "MWK",
  "MZ": "MZN",
};

String currencyForCountry(String? countryCode, {String fallback = "KES"}) {
  if (countryCode == null) return fallback;
  return currencyByCountry[countryCode.toUpperCase()] ?? fallback;
}
