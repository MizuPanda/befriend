import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../models/authentication.dart';

class LoginProvider extends ChangeNotifier {
  final _formKey = GlobalKey<FormState>();
  get formKey => _formKey;

  final FocusNode _emailFocusNode = FocusNode();
  FocusNode get emailFocusNode => _emailFocusNode;

  bool _isEmailFocused = false;
  bool get isEmailFocused => _isEmailFocused;

  final FocusNode _passwordFocusNode = FocusNode();
  FocusNode get passwordFocusNode => _passwordFocusNode;

  bool _isPasswordFocused = false;
  bool get isPasswordFocused => _isPasswordFocused;

  bool _passwordVisible = false;
  bool get passwordVisible => _passwordVisible;

  String? _email, _password;

  void emailSaved(String? value) {
    _email = value!.trim();
  }

  void passwordSaved(String? value) {
    _password = value!.trim();
  }

  TextInputType keyboardType() {
    return passwordVisible ? TextInputType.visiblePassword : TextInputType.text;
  }

  void init() {
    _emailFocusNode.addListener(() {
      _isEmailFocused = _emailFocusNode.hasFocus;
      notifyListeners();
    });
    _passwordFocusNode.addListener(() {
      _isPasswordFocused = _passwordFocusNode.hasFocus;
      notifyListeners();
    });
  }

  void toDispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
  }

  void hidePassword() {
    _passwordVisible = !_passwordVisible;
    notifyListeners();
  }

  void navigateToSignUp(BuildContext context) {
    GoRouter.of(context).push('/signup');
  }

  String? emailValidator(String? email) {
    if (email == null || email.isEmpty) {
      return 'Please enter your email';
    }

    return null;
  }

  String? passwordValidator(String? password) {
    if (password == null || password.isEmpty) {
      return 'Please enter your password';
    }

    return null;
  }

  Future<void> login(BuildContext context) async {
    _formKey.currentState!.save();
    if (_formKey.currentState!.validate()) {
      if (context.mounted) {
        await AuthenticationManager.signIn(_email!, _password!, context);
      }
    }
  }

  void forgotPassword() {}
}
