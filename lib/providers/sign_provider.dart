import 'dart:io';

import 'package:befriend/models/authentication/authentication.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:befriend/utilities/error_handling.dart';
import 'package:befriend/utilities/validators.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/data/picture_manager.dart';
import '../utilities/app_localizations.dart';
import '../utilities/date_manager.dart';
import '../utilities/password_strength.dart';

class SignProvider extends ChangeNotifier {
  late NavigatorState _navigator;

  bool? _hasConsented = false;

  bool? get hasConsented => _hasConsented;

  bool _passwordVisible = false;

  bool get passwordVisible => _passwordVisible;

  bool _passwordRepeatVisible = false;

  bool get passwordRepeatVisible => _passwordRepeatVisible;

  final _formKey = GlobalKey<FormState>();

  get formKey => _formKey;

  String? _email, _username, _password;
  String? _error;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  DateTime _date = DateTime(2022, 05, 09);

  DateTime get date => _date;

  String? _imagePath;

  bool imageNull() {
    return _imagePath == null;
  }

  ImageProvider image() {
    return Image.file(File(_imagePath!)).image;
  }

  Future<void> retrieveImage(BuildContext context) async {
    try {
      await PictureManager.takeProfilePicture(
        context,
        (String? url) {
          _imagePath = url;
        },
      );
      notifyListeners();
    } catch (e) {
      debugPrint('(SignProvider) Error retrieving image: $e');
      if (context.mounted) {
        ErrorHandling.showError(
            context,
            AppLocalizations.translate(context,
                key: 'snp_retrieve_error',
                defaultString: 'Error retrieving image. Please try again.'));
      }
    }
  }

  Future<void> removeImage() async {
    try {
      await File(_imagePath!).delete();
      _imagePath = null;
      notifyListeners();
    } catch (e) {
      debugPrint('(SignProvider) Error deleting picture');
    }
  }

  double strength() {
    return PasswordStrength.getPasswordStrength(_password);
  }

  bool isPasswordEmpty() {
    return _password == null || _password!.isEmpty;
  }

  void onDateTimeChanged(DateTime dateTime) {
    _date = dateTime;
    notifyListeners();
  }

  String dateText(BuildContext context) {
    // Get the current locale
    Locale currentLocale = Localizations.localeOf(context);

    // Create a DateFormat instance with the current locale
    DateFormat dateFormat = DateFormat.yMd(currentLocale.toString());

    return dateFormat.format(_date);
  }

  void onChanged(String password) {
    _password = password;
    notifyListeners();
  }

  //#region VALIDATORS
  String? emailValidator(String? email, BuildContext context) {
    String? validator = Validators.emailValidator(email, context);

    if (validator != null) {
      return validator;
    }

    final RegExp emailRegex = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$");
    if (!emailRegex.hasMatch(email!) || _error == Constants.invalidEmail) {
      if (_error == Constants.invalidEmail) {
        _error = null;
      }
      return AppLocalizations.translate(context,
          key: 'snp_email_invalid', defaultString: 'This email is not valid.');
    }
    if (_error == Constants.emailAlreadyInUse) {
      _error = null;
      return AppLocalizations.translate(context,
          key: 'snp_email_used',
          defaultString: "This email is already in use.");
    }

    return null;
  }

  String? usernameValidator(String? username, BuildContext context) {
    String? validator = Validators.usernameValidator(username, context);

    if (validator != null) {
      return validator;
    }

    if (_error == Constants.usernameError) {
      _error = null;
      return AppLocalizations.translate(context,
          key: 'snp_username_used',
          defaultString: "This username is already in use.");
    }

    return null;
  }

  String? passwordValidator(String? password, BuildContext context) {
    String? validator = Validators.passwordValidator(password, context);
    if (validator != null) {
      return validator;
    }

    if (_error == Constants.weakPassword) {
      _error = null;
      return AppLocalizations.translate(context,
          key: 'snp_password_weak',
          defaultString: 'Your password is too weak.');
    }

    return null;
  }

  String? repeatValidator(String? repeat, BuildContext context) {
    return Validators.repeatValidator(repeat, _password, context);
  }

  //#endregion

  //#region SAVED FUNCTION
  void emailSaved(String? value) {
    _email = value!.trim();
  }

  void usernameSaved(String? value) {
    _username = value!.trim();
  }

  void passwordSaved(String? value) {
    _password = value!.trim();
  }

  void onCheck(bool? value) {
    _hasConsented = value;
    notifyListeners();
  }

  //#endregion

  void changedDependencies(BuildContext context) {
    _navigator = Navigator.of(context);
  }

  void toDispose() {
    _navigator.focusNode.unfocus();
  }

  void hidePassword() {
    _passwordVisible = !_passwordVisible;
    notifyListeners();
  }

  void hideRepeat() {
    _passwordRepeatVisible = !_passwordRepeatVisible;
    notifyListeners();
  }

  void _showAgeRequirementSnackBar(BuildContext context) {
    ErrorHandling.showError(
        context,
        AppLocalizations.translate(context,
            key: 'snp_age_req',
            defaultString:
                'You must be at least 13 years old to create an account.'));
  }

  void _showConsentSnackBar(BuildContext context) {
    ErrorHandling.showError(
        context,
        AppLocalizations.translate(context,
            key: 'snp_cons_req',
            defaultString:
                'Please agree to the Privacy Policy and to the Terms and Conditions to continue with the sign-up process.'));
  }

  void _showUnknownErrorSnackBar(BuildContext context) {
    ErrorHandling.showError(
        context,
        AppLocalizations.translate(context,
            key: 'general_error_message5',
            defaultString:
                'An unknown error has occurred. Please try again later.'));
  }

  /// Sign up the user
  Future<void> signUp(BuildContext context) async {
    if (!DateManager.isOldEnough(birthday: _date, age: 13)) {
      _showAgeRequirementSnackBar(context);
    } else if (_hasConsented == null || !_hasConsented!) {
      _showConsentSnackBar(context);
    } else if (_error == Constants.unknownError) {
      _showUnknownErrorSnackBar(context);
    } else {
      _isLoading = true;
      notifyListeners();
      _formKey.currentState!.save();

      if (_formKey.currentState!.validate()) {
        bool usernameAvailable =
            await AuthenticationManager.checkUsernameAvailability(_username!);
        if (!usernameAvailable) {
          _error = Constants.usernameError;
          _formKey.currentState!.validate();
        } else {
          if (context.mounted) {
            _error = await AuthenticationManager.createUserWithEmailAndPassword(
                _email!,
                _password!,
                _username!,
                _date.year,
                _imagePath,
                context);
          }
          if (_error != null) {
            _formKey.currentState!.validate();
          }
        }
      }
      _isLoading = false;
      notifyListeners();
    }
  }
}
