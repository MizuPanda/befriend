import 'package:befriend/utilities/constants.dart';
import 'package:flutter/material.dart';

import '../../../utilities/app_localizations.dart';

class SetPrivateDialog {
  static void dialog(
      BuildContext context, String pictureId, Function(String) onSuccess) {
    final double width = MediaQuery.of(context).size.width;
    const double textButtonSize = 15.0;

    showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: Text(
              AppLocalizations.of(context)?.translate('spd_title') ??
                  'Set to private',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(
                AppLocalizations.of(context)?.translate('spd_content') ??
                    'This action cannot be undone. Only you and your friends will be able to view this picture.',
                style: const TextStyle(fontSize: 16)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(); // Dismiss the dialog
                },
                child: Text(
                  AppLocalizations.of(context)?.translate('dialog_cancel') ??
                      "Cancel",
                  style: const TextStyle(fontSize: textButtonSize),
                ),
              ),
              SizedBox(
                width: 10 / 448 * width,
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await Constants.picturesCollection.doc(pictureId).update({
                      Constants.publicDoc: false,
                    });
                  } catch (e) {
                    debugPrint(
                        '(SetPrivateDialog) Error setting public to private: $e');
                  }

                  if (context.mounted) {
                    Navigator.of(dialogContext).pop(); // Dismiss the dialog
                  }
                },
                child: Text(
                    AppLocalizations.of(context)
                            ?.translate('general_word_confirm') ??
                        'Confirm',
                    style: const TextStyle(fontSize: textButtonSize)),
              ),
            ],
          );
        });
  }
}
