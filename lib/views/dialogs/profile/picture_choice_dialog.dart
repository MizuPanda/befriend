import 'package:flutter/material.dart';

import '../../../utilities/app_localizations.dart';

class PictureChoiceDialog {
  static Future<void> showPictureChoiceDialog(
      BuildContext context, Function()? onTap1, Function()? onTap2) {
    final double height = MediaQuery.of(context).size.height;

    return showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title:  Text(AppLocalizations.of(context)?.translate('pcd_choice')??'Make a choice!'),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  GestureDetector(
                    onTap: onTap1,
                    child: Text(AppLocalizations.of(context)?.translate('pcd_gallery')??"Gallery"),
                  ),
                  Padding(padding: EdgeInsets.all(0.008 * height)),
                  GestureDetector(
                    onTap: onTap2,
                    child: Text(AppLocalizations.of(context)?.translate('pcd_camera')??"Camera"),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
