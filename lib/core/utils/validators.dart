class Validators {
  static String? required(String? v, {String field = 'This field'}) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return '$field is required';
    return null;
  }

  static String? email(String? v) {
    final t = (v ?? '').trim();

    if (t.isEmpty) {
      return 'Email is required';
    }

    if (t.contains('..') || t.startsWith('.') || t.endsWith('.')) {
      return 'Enter a valid email address';
    }

    // Reasonably strict email regex (practical, not RFC-overkill)
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(t)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  static String? identifier(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Email or phone is required';
    if (t.length > 254) return 'Email or phone is too long';
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
