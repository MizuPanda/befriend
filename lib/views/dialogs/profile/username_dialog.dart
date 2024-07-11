import 'package:flutter/material.dart';

import '../../../models/data/user_manager.dart';
import '../../../models/objects/bubble.dart';
import '../../../utilities/app_localizations.dart';

class UsernameDialog {
  static Future<void> showUsernamesDialog(
      BuildContext context, Iterable<dynamic> usernames) async {
    try {
      Bubble bubble = await UserManager.getInstance();

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              title: Text(
                  AppLocalizations.of(context)?.translate('ud_people') ??
                      "People in this picture"),
              children: usernames
                  .map((username) => SimpleDialogOption(
                        child: Text(bubble.username == username
                            ? AppLocalizations.of(context)
                                    ?.translate('general_word_you') ??
                                'You'
                            : username),
                      ))
                  .toList(),
            );
          },
        );
      }
    } catch (e) {
      debugPrint('(PictureCardProvider) Error showing usernames dialog: $e');
    }
  }
}
