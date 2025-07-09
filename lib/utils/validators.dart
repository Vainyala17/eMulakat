class Validators {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mobile number is required';
    }
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age is required';
    }
    final age = int.tryParse(value);
    if (age == null || age < 1 || age > 120) {
      return 'Enter a valid age between 1 and 120';
    }
    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }
    if (value.length < 10) {
      return 'Address must be at least 10 characters';
    }
    return null;
  }

  static String? validateIdNumber(String? value, String idType, int maxLength) {
    if (value == null || value.isEmpty) {
      return 'ID number is required';
    }

    switch (idType) {
      case 'Aadhar Card':
        if (!RegExp(r'^\d{12}$').hasMatch(value)) {
          return 'Aadhar card must be 12 digits';
        }
        break;
      case 'Pan Card':
        if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(value)) {
          return 'Invalid PAN card format';
        }
        break;
      case 'Driving License':
        if (value.length < 10 || value.length > 16) {
          return 'Driving license must be 10-16 characters';
        }
        break;
      case 'Passport':
        if (!RegExp(r'^[A-Z]{1}[0-9]{7}$').hasMatch(value)) {
          return 'Invalid passport format';
        }
        break;
      case 'Voter ID':
        if (!RegExp(r'^[A-Z]{3}[0-9]{7}$').hasMatch(value)) {
          return 'Invalid voter ID format';
        }
        break;
      default:
        if (value.length > maxLength) {
          return 'ID number cannot exceed $maxLength characters';
        }
    }
    return null;
  }

  static String? validateCaptcha(String? value, String expectedValue) {
    if (value == null || value.isEmpty) {
      return 'Please enter captcha';
    }
    if (value.toLowerCase() != expectedValue.toLowerCase()) {
      return 'Incorrect captcha';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}