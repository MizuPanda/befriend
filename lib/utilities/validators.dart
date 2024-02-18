import 'package:befriend/utilities/password_strength.dart';

class Validators {
  static double strength(String password) {
    return PasswordStrength.getPasswordStrength(password);
  }

  static String? emailValidator(String? email) {
    if (email == null || email.isEmpty) {
      return 'Please enter an email.';
    }

    return null;
  }

  static String? nameValidator(String? name) {
    if (name == null || name.isEmpty) {
      return 'Please enter your name';
    }
    // Minimum and maximum length requirements
    if (name.length < 2 || name.length > 35) {
      return 'Please enter a shorter or longer name.';
    }

    // Disallowed characters (example disallowed characters: <, >, &)
    final disallowedCharacters = RegExp(r'[<>]');
    if (disallowedCharacters.hasMatch(name)) {
      return 'Your name contains characters that are not allowed';
    }

    return null;
  }

  static String? usernameValidator(String? username) {
    if (username == null || username.isEmpty) {
      return "Please enter a username.";
    }
    // Minimum and maximum length requirements
    if (username.length < 2 || username.length > 20) {
      return 'This username is too short or too lengthy.';
    }

    // Allowed characters (alphanumeric, underscores, periods)
    final RegExp allowedCharacters = RegExp(r'^[a-zA-Z0-9_.]+$');
    if (!allowedCharacters.hasMatch(username)) {
      return 'This username contains characters that are not allowed.';
    }

    return null;
  }

  static String? passwordValidator(String? password) {
    if (password == null || password.isEmpty) {
      return 'Please enter a password';
    }
    if (password.length < 8) {
      return 'This password is too short.';
    }
    if (strength(password) <= 3) {
      return 'This password is not strong enough.';
    }

    return null;
  }

  static String? repeatValidator(String? repeat, String? password) {
    if (repeat == null || repeat.isEmpty) {
      return 'Please repeat your password.';
    }
    return repeat == password
        ? null
        : 'This password does not match with the first one.';
  }
}
