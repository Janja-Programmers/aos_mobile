class Validators {
  static String? required(String? v, {String field = 'This field'}) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return '$field is required';
    return null;
  }

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
    final t = v ?? '';
    if (t.length < min) return msg;
    return null;
  }

  static String? confirmPassword(String? v, String password) {
    if ((v ?? '').isEmpty) return 'Confirm password is required';
    if (v != password) return 'Passwords do not match';
    return null;
  }
}
