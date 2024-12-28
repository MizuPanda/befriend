import 'package:flutter/material.dart';

import '../../../utilities/app_localizations.dart';

class ContactDialog {
  static void showEmailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.translate(context,
              key: 'cd_email', defaultString: 'Contact Email')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  AppLocalizations.translate(context,
                      key: 'cd_need',
                      defaultString:
                          'If you need to contact us, please use the email below:'),
                ),
                const SizedBox(height: 10),
                const SelectableText(
                  'befriend.esc.app@gmail.com',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(AppLocalizations.translate(context,
                  key: 'dialog_close', defaultString: 'Close')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
