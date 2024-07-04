import 'package:flutter/material.dart';

import '../../../utilities/app_localizations.dart';

class ContactDialog {
  static void showEmailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)?.translate('cd_email')??'Contact Email'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  AppLocalizations.of(context)?.translate('cd_need')??'If you need to contact us, please use the email below:',
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
              child: Text(AppLocalizations.of(context)?.translate('dialog_close')??'Close'),
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
