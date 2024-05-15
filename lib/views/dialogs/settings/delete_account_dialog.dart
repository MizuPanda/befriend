import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DeleteAccountDialog {
  static Widget dialog(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      titleTextStyle: GoogleFonts.openSans(
          color: Theme.of(context).colorScheme.primary, fontSize: 26),
      contentTextStyle: GoogleFonts.openSans(
          fontStyle: FontStyle.italic,
          fontSize: 16,
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold),
      title: const Text('Delete Account'),
      content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
