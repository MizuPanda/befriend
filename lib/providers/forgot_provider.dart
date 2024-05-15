import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ForgotProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _emailController = TextEditingController();
  TextEditingController get emailController => _emailController;

  final FocusNode _focusNode = FocusNode();
  FocusNode get focusNode => _focusNode;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> resetPassword(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      const SnackBar successSnackBar = SnackBar(
        content: Text(
            'If your email address is in our records, you will receive a password reset email shortly.'),
        duration: Duration(seconds: 3),
        showCloseIcon: true,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(successSnackBar);
      }
    } catch (error) {
      debugPrint('(ForgotProvider) Error: ${error.toString()}');
      const SnackBar errorSnackBar = SnackBar(
        content: Text('Failed to send password reset email. Please try again.'),
        duration: Duration(seconds: 3),
        showCloseIcon: true,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(errorSnackBar);
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  void pop(BuildContext context) {
    GoRouter.of(context).pop();
  }
}
