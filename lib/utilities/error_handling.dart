import 'package:flutter/material.dart';

class ErrorHandling {
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        showCloseIcon: true,
      ),
    );
  }
}
