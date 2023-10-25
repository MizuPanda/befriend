import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

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

    await _auth
        .sendPasswordResetEmail(email: _emailController.text.trim())
        .onError((error, stackTrace) {
      debugPrint('(ForgotPassword) Error: ${error.toString()}');
    });
    _isLoading = false;
    notifyListeners();

    if (context.mounted) {
      showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.info(
            message:
                'If your email address is in our records, you will receive a password reset email shortly.',
          ),
          snackBarPosition: SnackBarPosition.bottom);
    }
  }

  void pop(BuildContext context) {
    GoRouter.of(context).pop();
  }
}
