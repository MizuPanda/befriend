import 'package:flutter/material.dart';

import '../../../utilities/app_localizations.dart';

class CaptionDialog {
  static Future<String?> showCaptionDialog(
    BuildContext context,
    int characterLimit,
  ) {
    TextEditingController captionController = TextEditingController();

    return showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            actionsAlignment: MainAxisAlignment.spaceEvenly,
            title: Text(AppLocalizations.of(context)?.translate('cd_enter') ??
                'Enter a Caption'),
            content: TextField(
              controller: captionController,
              decoration: InputDecoration(
                hintText:
                    AppLocalizations.of(context)?.translate('cd_picture') ??
                        "Caption for the picture",
                counterText:
                    '${AppLocalizations.of(context)?.translate('cd_characters') ?? 'Characters limit:'} $characterLimit', // Optional: Hide the counter text
              ),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              maxLength: characterLimit, // Enforces the character limit
            ),
            actions: [
              TextButton(
                child: Text(
                  AppLocalizations.of(context)?.translate('dialog_cancel') ??
                      'Cancel',
                  textAlign: TextAlign.end,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text(
                  AppLocalizations.of(context)?.translate('dialog_publish') ??
                      'Publish',
                  textAlign: TextAlign.end,
                ),
                onPressed: () {
                  Navigator.of(context).pop(captionController.text.trim());
                },
              ),
            ],
          );
        });
  }
}
