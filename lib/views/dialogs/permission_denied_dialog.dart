import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../utilities/app_localizations.dart';

class PermissionDeniedDialog {
  static Future<void> showPermissionDeniedDialog(BuildContext context, String rationale) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)?.translate('pdd_required')??'Permission Required'),
          content: Text(rationale),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)?.translate('dialog_proceed')??'Proceed'),
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