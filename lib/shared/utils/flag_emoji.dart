String flagEmoji(String countryCode) {
  final code = countryCode.toUpperCase();
  if (code.length != 2) return '🏳️';
  final first = code.codeUnitAt(0) - 65 + 0x1F1E6;
  final second = code.codeUnitAt(1) - 65 + 0x1F1E6;
  return String.fromCharCode(first) + String.fromCharCode(second);
}
