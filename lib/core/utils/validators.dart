class AppValidator {
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? isName(String? value, {String fieldName = 'Full name'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  static String? isNumber(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final number = double.tryParse(value.trim());
    if (number == null) {
      return '$fieldName must be a valid number';
    }
    return null;
  }

  static String? isEmail(String? value, {String fieldName = 'Email'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");

    if (!emailRegex.hasMatch(value.trim())) {
      return '$fieldName must be a valid email address';
    }

    return null;
  }

  static String? isPhone(String? val) {
    if (val == null || val.trim().isEmpty) return 'Phone number is required';

    final value = val.trim();

    final regex = RegExp(r'^(\+254|254|0)(7|1)[0-9]{8}$');

    if (!regex.hasMatch(value)) {
      return 'Enter a valid Kenyan phone number';
    }

    return null;
  }

  static String? isPassword(String? val) {
    if (val == null || val.isEmpty) return 'Password is required';
    if (val.length < 8) return 'Must be at least 6 characters';
    return null;
  }

  static String? isConfirmPassword(String? val) {
    if (val == null || val.isEmpty) return 'Confirm password required';
    if (val.length < 8) return 'Must be at least 6 characters';
    return null;
  }
}
