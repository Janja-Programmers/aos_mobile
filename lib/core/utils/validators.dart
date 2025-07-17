class AppValidator {
  static String? required(String? value, {String fieldName = 'This field'}) {
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

    // final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    print('Validating email: $value'); // Debugging line
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{0,4}$");

    if (!emailRegex.hasMatch(value.trim())) {
      return '$fieldName must be a valid email address';
    }

    return null;
  }
}
