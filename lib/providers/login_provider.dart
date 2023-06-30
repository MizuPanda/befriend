import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

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

  void login() {}

  void forgotPassword() {}
}
