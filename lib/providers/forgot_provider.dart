import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../utilities/app_localizations.dart';

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
      final SnackBar successSnackBar = SnackBar(
        content: Text(
            context.mounted? AppLocalizations.of(context)?.translate('fp_reset')??'If your email address is in our records, you will receive a password reset email shortly.' : 'If your email address is in our records, you will receive a password reset email shortly.'),
        duration: const Duration(seconds: 3),
        showCloseIcon: true,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(successSnackBar);
      }
    } catch (error) {
      debugPrint('(ForgotProvider) Error: ${error.toString()}');
      final SnackBar errorSnackBar = SnackBar(
        content: Text(context.mounted? AppLocalizations.of(context)?.translate('fp_reset_error')?? 'Failed to send password reset email. Please try again.' : 'Failed to send password reset email. Please try again.'),
        duration: const Duration(seconds: 3),
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
