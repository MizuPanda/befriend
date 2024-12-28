import 'package:befriend/utilities/password_strength.dart';
import 'package:flutter/cupertino.dart';

import 'app_localizations.dart';

class Validators {
  static const int maxBioLength = 50;

  static double strength(String password) {
    return PasswordStrength.getPasswordStrength(password);
  }

  static String? emailValidator(String? email, BuildContext context) {
    if (email == null || email.isEmpty) {
      return AppLocalizations.translate(context,
          key: 'val_email', defaultString: 'Please enter an email.');
    }

    return null;
  }

  static String? usernameValidator(String? username, BuildContext context) {
    if (username == null || username.isEmpty) {
      return AppLocalizations.translate(context,
          key: 'val_username_empty', defaultString: "Please enter a username.");
    }
    username.trim();
    // Minimum and maximum length requirements
    if (username.length < 2 || username.length > 20) {
      return AppLocalizations.translate(context,
          key: 'val_username_length',
          defaultString: 'This username is too short or too lengthy.');
    }

    // Allowed characters (alphanumeric, underscores, periods)
    final RegExp allowedCharacters = RegExp(r'^[a-zA-Z0-9_.]+$');
    if (!allowedCharacters.hasMatch(username)) {
      return AppLocalizations.translate(context,
          key: 'val_username_char',
          defaultString:
              'This username contains characters that are not allowed.');
    }

    return null;
  }

  static String? passwordValidator(String? password, BuildContext context) {
    if (password == null || password.isEmpty) {
      return AppLocalizations.translate(context,
          key: 'val_password_empty', defaultString: 'Please enter a password');
    }
    if (password.length < 8) {
      return AppLocalizations.translate(context,
          key: 'val_password_short',
          defaultString: 'This password is too short.');
    }
    if (strength(password) <= 3) {
      return AppLocalizations.translate(context,
          key: 'val_password_weak',
          defaultString: 'This password is not strong enough.');
    }

    return null;
  }

  static String? repeatValidator(
      String? repeat, String? password, BuildContext context) {
    if (repeat == null || repeat.isEmpty) {
      return AppLocalizations.translate(context,
          key: 'val_repeat_empty',
          defaultString: 'Please repeat your password.');
    }
    return repeat == password
        ? null
        : AppLocalizations.translate(context,
            key: 'val_repeat_incorrect',
            defaultString: 'This password does not match with the first one.');
  }

  static String? bioValidator(String? bio, BuildContext context) {
    if (bio != null && bio.length > maxBioLength) {
      return AppLocalizations.translate(context,
          key: 'val_bio_length', defaultString: "This bio is too lengthy.");
    }
    return null;
  }
}
