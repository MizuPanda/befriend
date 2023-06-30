import 'package:flutter/material.dart';

class SignProvider extends ChangeNotifier {
  bool _passwordVisible = false;
  bool get passwordVisible => _passwordVisible;

  bool _passwordRepeatVisible = false;
  bool get passwordRepeatVisible => _passwordRepeatVisible;

  late NavigatorState _navigator;

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

  void signup() {}
}
