class Validators {
  // Full Name: Only letters and spaces, min 2 characters
  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    final nameRegExp = RegExp(r'^[a-zA-Z\s]+$');
    if (!nameRegExp.hasMatch(value.trim())) {
      return 'Name can only contain letters and spaces';
    }
    return null; // valid
  }

  // Email: Standard email regex
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegExp = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}$');
    if (!emailRegExp.hasMatch(value.trim())) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? validateName(String? value, {String fieldName = 'Name'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    if (value.trim().length < 2) {
      return '$fieldName must be at least 2 characters';
    }

    final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
    if (!nameRegex.hasMatch(value.trim())) {
      return '$fieldName can only contain letters';
    }

    return null;
  }


  // Password: min 6 chars, at least 1 uppercase, 1 lowercase, 1 number
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // Confirm Password: matches password
  static String? validateConfirmPassword(
      String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Mobile Number: 10 digits, optional +country code
  static String? validateMobile(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile number is required';
    }
    final mobileRegExp = RegExp(r'^\+?\d{10,14}$');
    if (!mobileRegExp.hasMatch(value.trim())) {
      return 'Enter a valid mobile number';
    }
    return null;
  }

  // OTP: 4-6 digits
  static String? validateOTP(String? value, {int length = 4}) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }
    final otpRegExp = RegExp(r'^\d+$');
    if (!otpRegExp.hasMatch(value)) {
      return 'OTP must be digits only';
    }
    if (value.length != length) {
      return 'OTP must be $length digits';
    }
    return null;
  }

  // Address : 5 lengt
  static String? validateStreetAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Street address is required';
    }

    if (value.trim().length < 5) {
      return 'Please enter a valid street address';
    }

    final RegExp addressRegex =
    RegExp(r'^[a-zA-Z0-9\s,.\-/#]+$');

    if (!addressRegex.hasMatch(value)) {
      return 'Invalid characters in address';
    }

    return null; // ✅ valid
  }


  static String? validateRequire(String? val, String msg) {
    if (val == null || val.trim().isEmpty) {
      return msg;
    }
    return null;
  }

  static String? validateNumbers(String? val, String msg) {
    if (val == null || val.trim().isEmpty) {
      return msg;
    }
    if (int.tryParse(val) == null) {
      return 'Enter valid number';
    }
    return null;
  }


}