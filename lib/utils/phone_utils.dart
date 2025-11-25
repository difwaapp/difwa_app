String? normalizeToE164(String raw, {String defaultCountryCode = '+91'}) {
  String s = raw.trim();
  s = s.replaceAll(RegExp(r'[\s\-\(\)]'), ''); // remove separators
  if (s.startsWith('00')) s = s.replaceFirst('00', '+');

  // already +...
  if (s.startsWith('+')) {
    return RegExp(r'^\+\d{6,15}$').hasMatch(s) ? s : null;
  }

  // digits only: strip leading zeros then prepend default code
  if (RegExp(r'^\d+$').hasMatch(s)) {
    if (s.startsWith('0')) s = s.replaceFirst(RegExp(r'^0+'), '');
    final candidate = defaultCountryCode + s;
    return RegExp(r'^\+\d{6,15}$').hasMatch(candidate) ? candidate : null;
  }

  return null;
}
