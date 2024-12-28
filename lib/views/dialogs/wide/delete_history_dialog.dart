import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utilities/app_localizations.dart';

class DeleteHistoryDialog {
  static Future<void> showDeleteHistoryDialog(
      BuildContext context, Function onConfirm) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        bool isLoading = false;

        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(
              AppLocalizations.translate(context,
                  key: 'dhd_title', defaultString: 'Clear search history?'),
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(fontWeight: FontWeight.bold),
            ),
            content: Text(
              AppLocalizations.translate(context,
                  key: 'dhd_content',
                  defaultString:
                      'Are you sure you want to clear your search history? This action cannot be undone.'),
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(),
            ),
            actionsAlignment: MainAxisAlignment.spaceEvenly,
            actions: isLoading
                ? [const CircularProgressIndicator()]
                : [
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(); // Close the dialog
                      },
                      child: Text(
                        AppLocalizations.translate(context,
                            key: 'dialog_cancel', defaultString: 'Cancel'),
                        style: GoogleFonts.openSans(),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });

                        await onConfirm(); // Trigger the delete action

                        if (context.mounted) {
                          Navigator.of(dialogContext)
                              .pop(); // Dismiss the dialog
                        }
                      },
                      style: const ButtonStyle(
                        foregroundColor:
                            WidgetStatePropertyAll<Color?>(Colors.red),
                      ),
                      child: Text(
                        AppLocalizations.translate(context,
                            key: 'dialog_delete', defaultString: 'Delete'),
                        style: GoogleFonts.openSans(),
                      ),
                    ),
                  ],
          );
        });
      },
    );
  }
}
