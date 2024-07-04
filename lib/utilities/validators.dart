import 'package:befriend/utilities/password_strength.dart';
import 'package:flutter/cupertino.dart';

import 'app_localizations.dart';

class Validators {
  static double strength(String password) {
    return PasswordStrength.getPasswordStrength(password);
  }

  static String? emailValidator(String? email, BuildContext context) {
    if (email == null || email.isEmpty) {
      return AppLocalizations.of(context)?.translate('val_email')??'Please enter an email.';
    }

    return null;
  }

  static String? usernameValidator(String? username, BuildContext context) {
    if (username == null || username.isEmpty) {
      return AppLocalizations.of(context)?.translate('val_username_empty')??"Please enter a username.";
    }
    username.trim();
    // Minimum and maximum length requirements
    if (username.length < 2 || username.length > 20) {
      return AppLocalizations.of(context)?.translate('val_username_length')??'This username is too short or too lengthy.';
    }

    // Allowed characters (alphanumeric, underscores, periods)
    final RegExp allowedCharacters = RegExp(r'^[a-zA-Z0-9_.]+$');
    if (!allowedCharacters.hasMatch(username)) {
      return AppLocalizations.of(context)?.translate('val_username_char')??'This username contains characters that are not allowed.';
    }

    return null;
  }

  static String? passwordValidator(String? password, BuildContext context) {
    if (password == null || password.isEmpty) {
      return AppLocalizations.of(context)?.translate('val_password_empty')??'Please enter a password';
    }
    if (password.length < 8) {
      return AppLocalizations.of(context)?.translate('val_password_short')??'This password is too short.';
    }
    if (strength(password) <= 3) {
      return AppLocalizations.of(context)?.translate('val_password_weak')??'This password is not strong enough.';
    }

    return null;
  }

  static String? repeatValidator(String? repeat, String? password, BuildContext context) {
    if (repeat == null || repeat.isEmpty) {
      return AppLocalizations.of(context)?.translate('val_repeat_empty')??'Please repeat your password.';
    }
    return repeat == password
        ? null
        : AppLocalizations.of(context)?.translate('val_repeat_incorrect')??'This password does not match with the first one.';
  }
}
