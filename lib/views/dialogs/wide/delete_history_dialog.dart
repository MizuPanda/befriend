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
              AppLocalizations.of(context)?.translate('dhd_title') ??
                  'Clear search history?',
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(fontWeight: FontWeight.bold),
            ),
            content: Text(
              AppLocalizations.of(context)?.translate('dhd_content') ??
                  'Are you sure you want to clear your search history? This action cannot be undone.',
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
                        AppLocalizations.of(context)
                                ?.translate('dialog_cancel') ??
                            'Cancel',
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
                        AppLocalizations.of(dialogContext)
                                ?.translate('dialog_delete') ??
                            'Delete',
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
