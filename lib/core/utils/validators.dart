class Validators {
  static String? email(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Email is required';
    if (!t.contains('@')) return 'Enter a valid email';
    return null;
  }

  static String? passwordRequired(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Password is required';
    return null;
  }

  static String? minLen(String? v, int min, String msg) {
    final t = (v ?? '');
    if (t.length < min) return msg;
    return null;
  }
}
