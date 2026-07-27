String? flagEmojiOrNull(String countryCode) {
  final code = countryCode.trim().toUpperCase();
  if (!RegExp(r'^[A-Z]{2}$').hasMatch(code)) return null;

  return String.fromCharCodes(code.codeUnits.map((unit) => unit + 0x1F1A5));
}

String flagEmoji(String countryCode) {
  return flagEmojiOrNull(countryCode) ?? '';
}
