import 'package:flutter/material.dart';

import '../../../utilities/app_localizations.dart';

class DeletePictureDialog {
  static void showDeletePictureDialog(
      BuildContext context, Function onPressed) {
    const double textButtonSize = 15.0;
    final double width = MediaQuery.of(context).size.width;

    showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          bool isLoading = false;

          return StatefulBuilder(builder: (BuildContext context, setState) {
            return AlertDialog(
              title: Text(
                AppLocalizations.translate(context,
                    key: 'dpd_title', defaultString: 'Delete this picture'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Text.rich(TextSpan(children: [
                TextSpan(
                    text: AppLocalizations.translate(context,
                        key: 'dpd_content',
                        defaultString:
                            "Are you sure you want to delete this picture. This will also delete the picture on your friends profile. This action cannot be undone.\n\n"),
                    style: const TextStyle(fontSize: 15)),
                TextSpan(
                    text: AppLocalizations.translate(context,
                        key: 'dpd_note',
                        defaultString:
                            "Note: You are able to delete this picture because it was taken with your device. Please archive the picture if you only want to hide it from your profile."),
                    style: const TextStyle(
                        fontSize: 12, fontStyle: FontStyle.italic))
              ])),
              actions: isLoading
                  ? [const CircularProgressIndicator()]
                  : [
                      TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext)
                              .pop(); // Dismiss the dialog
                        },
                        child: Text(
                          AppLocalizations.translate(context,
                              key: 'dialog_cancel', defaultString: "Cancel"),
                          style: const TextStyle(fontSize: textButtonSize),
                        ),
                      ),
                      SizedBox(
                        width: 10 / 448 * width,
                      ),
                      TextButton(
                        onPressed: () async {
                          setState(() {
                            isLoading = true;
                          });

                          //await Future.delayed(const Duration(seconds: 2));
                          await onPressed();

                          setState(() {
                            isLoading = false;
                          });

                          if (context.mounted) {
                            Navigator.of(dialogContext)
                                .pop(); // Dismiss the dialog
                          }
                        },
                        child: Text(
                            AppLocalizations.translate(context,
                                key: 'dialog_delete', defaultString: 'Delete'),
                            style: const TextStyle(
                                color: Colors.red, fontSize: textButtonSize)),
                      ),
                    ],
            );
          });
        });
  }
}
