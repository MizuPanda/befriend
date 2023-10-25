class PasswordStrength {
  static const double max = 4.5;

  static double getPasswordStrength(String? password) {
    if (password == null || password.isEmpty) {
      return 0;
    }
    double strengthScore = 0;

    if (password.length > 8) {
      strengthScore += 0.5;
    }

    // Evaluate different characteristics (e.g., uppercase, lowercase, numbers, special characters)
    if (RegExp(r'[A-Z]').hasMatch(password)) {
      strengthScore++;
    }
    if (RegExp(r'[a-z]').hasMatch(password)) {
      strengthScore++;
    }
    if (RegExp(r'\d').hasMatch(password)) {
      strengthScore++;
    }
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      strengthScore++;
    }

    return strengthScore;
  }
}
