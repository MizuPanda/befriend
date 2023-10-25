import 'package:befriend/models/authentication.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import '../utilities/password_strength.dart';

class SignProvider extends ChangeNotifier {
  late NavigatorState _navigator;

  bool _passwordVisible = false;

  bool get passwordVisible => _passwordVisible;

  bool _passwordRepeatVisible = false;

  bool get passwordRepeatVisible => _passwordRepeatVisible;

  final _formKey = GlobalKey<FormState>();

  get formKey => _formKey;

  String? _email, _name, _username, _password;
  String? _error;
  static const String _usernameError = 'username-already-in-use';

  bool _loading = false;

  bool get loading => _loading;

  double strength() {
    return PasswordStrength.getPasswordStrength(_password);
  }

  void onChanged(String password) {
    _password = password;
    notifyListeners();
  }

  //#region VALIDATORS
  String? emailValidator(String? email) {
    if (email == null || email.isEmpty) {
      return 'Please enter an email.';
    }
    final RegExp emailRegex = RegExp(
        r"^[a-zA-Z0-9.!#$%&\'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$");
    if (!emailRegex.hasMatch(email) || _error == 'invalid-email') {
      if (_error == 'invalid-email') {
        _error = null;
      }
      return 'This email is not valid.';
    }
    if (_error == 'email-already-in-use') {
      _error = null;
      return "This email is already in use.";
    }

    return null;
  }

  String? nameValidator(String? name) {
    if (name == null || name.isEmpty) {
      return 'Please enter your name';
    }
    // Minimum and maximum length requirements
    if (name.length < 2 || name.length > 30) {
      return 'Please enter a shorter or longer name.';
    }

    // Disallowed characters (example disallowed characters: <, >, &)
    final disallowedCharacters = RegExp(r'[<>]');
    if (disallowedCharacters.hasMatch(name)) {
      return 'Your name contains characters that are not allowed';
    }

    return null;
  }

  String? usernameValidator(String? username) {
    if (username == null || username.isEmpty) {
      return "Please enter a username.";
    }
    // Minimum and maximum length requirements
    if (username.length < 6 || username.length > 15) {
      return 'This username is too short or too lengthy.';
    }

    // Allowed characters (alphanumeric, underscores, periods)
    final RegExp allowedCharacters = RegExp(r'^[a-zA-Z0-9_.]+$');
    if (!allowedCharacters.hasMatch(username)) {
      return 'This username contains characters that are not allowed.';
    }

    if (_error == _usernameError) {
      _error = null;
      return "This username is already in use.";
    }

    return null;
  }

  String? passwordValidator(String? password) {
    if (password == null || password.isEmpty) {
      return 'Please enter a password';
    }
    if (password.length < 8) {
      return 'This password is too short.';
    }
    if (strength() <= 3) {
      return 'This password is not strong enough.';
    }

    return null;
  }

  String? repeatValidator(String? repeat) {
    if (repeat == null || repeat.isEmpty) {
      return 'Please repeat your password.';
    }
    return repeat == _password
        ? null
        : 'This password does not match with the first one.';
  }

  //#endregion

  //#region SAVED FUNCTION
  void emailSaved(String? value) {
    _email = value!.trim();
  }

  void nameSaved(String? value) {
    _name = value!.trim();
  }

  void usernameSaved(String? value) {
    _username = value!.trim();
  }

  void passwordSaved(String? value) {
    _password = value!.trim();
  }

  //#endregion

  Future<bool> _checkUsernameAvailability(String username) async {
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'checkUsernameAvailability',
    );

    try {
      final result = await callable.call({'username': username});
      final isUsernameAvailable = result.data['isUsernameAvailable'] as bool;
      return isUsernameAvailable;
    } catch (error) {
      // Handle any errors that occurred during the cloud function call
      debugPrint('Error: $error');
      return false;
    }
  }

  void changedDependencies(BuildContext context) {
    _navigator = Navigator.of(context);
  }

  void toDispose() {
    _navigator.focusNode.unfocus();
    notifyListeners();
  }

  void hidePassword() {
    _passwordVisible = !_passwordVisible;
    notifyListeners();
  }

  void hideRepeat() {
    _passwordRepeatVisible = !_passwordRepeatVisible;
    notifyListeners();
  }

  /// Sign up the user
  Future<void> signUp(BuildContext context) async {
    _loading = true;
    notifyListeners();
    _formKey.currentState!.save();

    if (_formKey.currentState!.validate()) {
      bool usernameAvailable = await _checkUsernameAvailability(_username!);
      if (!usernameAvailable) {
        _error = _usernameError;
        _formKey.currentState!.validate();
      } else {
        if (context.mounted) {
          _error = await AuthenticationManager.createUserWithEmailAndPassword(
              _email!, _password!, _name!, _username!, context);
        }
        if (_error != null) {
          _formKey.currentState!.validate();
        }
      }
    }
    _loading = false;
    notifyListeners();
  }
}
