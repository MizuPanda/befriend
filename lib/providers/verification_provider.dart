import 'package:befriend/models/authentication.dart';
import 'package:flutter/cupertino.dart';

class VerificationProvider extends ChangeNotifier {
  final TextEditingController _codeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  GlobalKey<FormState> get formKey => _formKey;
  TextEditingController get codeController => _codeController;

  String? _error;

  void toDispose() {
    _codeController.dispose();
  }

  Future<void> verifyCode() async {
    // Add your verification logic here
    String enteredCode = _codeController.text;
    _error = await AuthenticationManager.verifyEmail(enteredCode);
    if (!_formKey.currentState!.validate()) {
      _codeController.clear();
    }
    //IF VALID -> GO ON NEXT PAGE (AVATAR FIRST TAKING)
  }

  String? validator(String? code) {
    if (code == null || code.isEmpty) {
      return 'Please enter the code you received in your mail';
    }
    if (_error == 'expired-action-code') {
      _error = null;
      return 'The code you entered is expired';
    }
    if (_error == 'invalid-action-code') {
      _error = null;
      return 'The code you entered is incorrect';
    }
    if (_error != null) {
      _error = null;
      return 'Error. Please try again!';
    }

    return null;
  }
}
