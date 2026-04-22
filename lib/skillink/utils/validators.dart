class Validators {
  Validators._();

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final _phoneRegex = RegExp(
    r'^(\+92[0-9]{10}|03[0-9]{9})$',
  );

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one digit';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (!_phoneRegex.hasMatch(value.trim())) {
      return 'Enter a valid phone number (+92XXXXXXXXXX or 03XXXXXXXXX)';
    }
    return null;
  }

  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static final _cnicRegex = RegExp(r'^\d{5}-\d{7}-\d$');

  static String? cnic(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'CNIC number is required';
    }
    if (!_cnicRegex.hasMatch(value.trim())) {
      return 'Enter a valid CNIC (XXXXX-XXXXXXX-X)';
    }
    return null;
  }

  static String normalizePhone(String phone) {
    final trimmed = phone.trim();
    if (trimmed.startsWith('03')) {
      return '+92${trimmed.substring(1)}';
    }
    return trimmed;
  }
}
