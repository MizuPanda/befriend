import 'package:flutter/material.dart';

import '../../../models/data/user_manager.dart';
import '../../../models/objects/bubble.dart';
import '../../../utilities/app_localizations.dart';

class LikesDialog {
  static Future<void> showLikesDialog(
      BuildContext context, List<dynamic> likes) async {
    try {
      Bubble bubble = await UserManager.getInstance();

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              title: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_rounded,
                    color: Colors.red,
                  ),
                  Icon(
                    Icons.favorite_rounded,
                    color: Colors.red,
                  ),
                  Icon(
                    Icons.favorite_rounded,
                    color: Colors.red,
                  )
                ],
              ),
              children: likes
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
      debugPrint('(PictureCardProvider) Error showing likes dialog: $e');
    }
  }
}
