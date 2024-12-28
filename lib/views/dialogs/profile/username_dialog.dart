import 'package:befriend/models/authentication/authentication.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/objects/bubble.dart';
import '../../../utilities/app_localizations.dart';

class UsernameDialog {
  static Future<void> showUsernamesDialog(
      BuildContext context, List<Bubble> users) async {
    try {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              titleTextStyle: GoogleFonts.openSans(fontSize: 18),
              title: Text(
                AppLocalizations.translate(context,
                    key: 'ud_people', defaultString: "People in this picture"),
                textAlign: TextAlign.center,
              ),
              children: users
                  .map((user) => SimpleDialogOption(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: user.avatar,
                          ),
                          title: Text(AuthenticationManager.id() == user.id
                              ? AppLocalizations.translate(context,
                                  key: 'general_word_you', defaultString: 'You')
                              : user.username),
                        ),
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
