abstract final class AppRegExp {
  /// Letters in any language (Arabic included), spaces, `'` and `-`.
  static bool isNameValid(String name) {
    return RegExp(
      r"^[\p{L}\p{M}' \-]{2,}$",
      unicode: true,
    ).hasMatch(name.trim());
  }

  static bool isEmailValid(String email) {
    return RegExp(
      r"^[\w.+\-]+@[\w\-]+(\.[\w\-]+)*\.[a-zA-Z]{2,}$",
    ).hasMatch(email.trim());
  }

  /// Egyptian mobile: 010 / 011 / 012 / 015 + 8 digits.
  static bool isPhoneNumberValid(String phoneNumber) {
    return RegExp(r"^01[0125][0-9]{8}$").hasMatch(phoneNumber);
  }

  static bool isOTPValid(String otp) {
    return RegExp(r"^[0-9]{6}$").hasMatch(otp);
  }

  /// At least 8 characters — the school API's rule.
  static bool isPasswordValid(String password) {
    return RegExp(r"^.{8,}$").hasMatch(password);
  }
}
