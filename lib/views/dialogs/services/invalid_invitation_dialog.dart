import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utilities/app_localizations.dart';

class InvalidInvitationDialog {
  static void dialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)?.translate('iid_title') ??
                'Invalid Invitation',
            textAlign: TextAlign.center,
          ),
          content: Text(
            AppLocalizations.of(context)?.translate('iid_content') ??
                'The invitation link is invalid or has already been used.',
            textAlign: TextAlign.center,
            style: GoogleFonts.openSans(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                  AppLocalizations.of(context)?.translate('dialog_ok') ?? 'OK'),
            ),
          ],
        );
      },
    );
  }
}
