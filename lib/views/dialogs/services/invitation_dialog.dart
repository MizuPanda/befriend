import 'package:befriend/models/services/referral_service.dart';
import 'package:befriend/views/widgets/users/profile_photo.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/objects/bubble.dart';
import '../../../utilities/app_localizations.dart';

class InvitationDialog {
  static void dialog(BuildContext context, Bubble referer, Bubble userBubble,
      String token, Map<String, dynamic> inviteTokens) {
    double height = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            textAlign: TextAlign.center,
            AppLocalizations.of(dialogContext)?.translate('id_title') ??
                'Friend Request',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ProfilePhoto(user: referer, radius: 20),
              SizedBox(height: 16.0 / 978 * height),
              Text.rich(
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(),
                TextSpan(
                  children: [
                    TextSpan(
                      text: referer.username,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          ' ${AppLocalizations.of(dialogContext)?.translate('id_content') ?? 'has invited you to be friends. Do you accept?'}',
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    // Handle rejection
                  },
                  child: Text(
                    AppLocalizations.of(dialogContext)
                            ?.translate('general_word_no') ??
                        'No',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    // Handle acceptance
                    await ReferralService.addFriend(
                        context,
                        referer,
                        userBubble,
                        token,
                        inviteTokens); // Assuming Bubble has id and token fields
                  },
                  child: Text(
                    AppLocalizations.of(dialogContext)
                            ?.translate('general_word_yes') ??
                        'Yes',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
