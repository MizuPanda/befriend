import 'package:befriend/models/authentication/authentication.dart';
import 'package:flutter/material.dart';

class EmailVerifiedDialog {
  static void dialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Email Verification Required'),
        content: const Text('Please verify your email to access this feature.'),
        actions: [
          TextButton(
            onPressed: () {
              AuthenticationManager.sendEmailVerification(context);
              Navigator.of(context).pop();
            },
            child: const Text('Resend Email'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
