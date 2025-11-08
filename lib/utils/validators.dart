// validators.dart

class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$'); // Restrict to @gmail.com
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid Gmail address (e.g., example@gmail.com)';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^\d{10}\$');
    if (!phoneRegex.hasMatch(value)) {}
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    // if (!RegExp(r'^[A-Z][a-zA-Z ]*$').hasMatch(value)) {
    //   return 'Name must start with a capital letter and contain only letters';
    // }
    return null;
  }

  static String? validateEmpty(String? value, String? fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    // if (!RegExp(r'^[A-Z][a-zA-Z ]*$').hasMatch(value)) {
    //   return 'Name must start with a capital letter and contain only letters';
    // }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}\$').hasMatch(value)) {}
    return null;
  }

  static String? validateState(String? value) {
    if (value == null || value.isEmpty) {
      return 'State is required';
    }

    return null; // Return null if the value passes validation
  }

  static String? validateCity(String? value) {
    if (value == null || value.isEmpty) {
      return 'City is required';
    }

    return null; // Return null if the value passes validation
  }

  static String? validateHouseNumberBuilding(String? value) {
    if (value == null || value.isEmpty) {
      return 'House No./Building Name is required';
    }

    return null; // Return null if the value passes validation
  }

  static String? validatePin(String? value) {
    // Check if the value is null or empty
    if (value == null || value.isEmpty) {
      return 'Pincode is required';
    }

    // Check if the value is exactly 6 digits
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'Pincode must be a 6-digit number';
    }

    return null;
  }

  String? validateLandMark(String? value) {
    if (value == null || value.isEmpty) {
      return 'Road name, Area, Landmark is required';
    }

    return null;
  }

  static String? validateRequiredField(String? value, String? fieldName) {
    if (value == null) {
      return '$fieldName is required';
    }
    return null;
  }
}


// vadidation for the vandor form page 

