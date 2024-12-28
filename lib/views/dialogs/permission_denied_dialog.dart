import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../utilities/app_localizations.dart';

class PermissionDeniedDialog {
  static Future<void> showPermissionDeniedDialog(
      BuildContext context, String rationale) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.translate(context,
              key: 'pdd_required', defaultString: 'Permission Required')),
          content: Text(rationale),
          actions: [
            TextButton(
              child: Text(AppLocalizations.translate(context,
                  key: 'dialog_proceed', defaultString: 'Proceed')),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }
}
