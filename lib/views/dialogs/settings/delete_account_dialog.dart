import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utilities/app_localizations.dart';

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
      title:  Text(AppLocalizations.of(context)?.translate('dad_da')??'Delete Account'),
      content: Text(AppLocalizations.of(context)?.translate('dad_conf')??
          'Are you sure you want to delete your account? This action cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child:  Text(AppLocalizations.of(context)?.translate('dialog_cancel')??'Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(AppLocalizations.of(context)?.translate('dialog_delete')??'Delete', style: const TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
