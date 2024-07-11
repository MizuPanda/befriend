import 'package:auto_size_text/auto_size_text.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/objects/friendship_progress.dart';
import '../../../utilities/app_localizations.dart';

class VisibilityDialog {
  static void showVisibilityDialog(BuildContext context,
      {required bool isAllPublic,
      required bool isPrivate,
      required Set<FriendshipProgress> friendships}) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            width: width * Constants.pictureDialogWidthMultiplier,
            height: height * Constants.pictureDialogHeightMultiplier,
            child: VisibilitySettingsWidget(
              isAllPublic: isAllPublic,
              isPrivate: isPrivate,
              friendships: friendships,
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                AppLocalizations.of(context)?.translate('dialog_close') ??
                    'Close',
                style: GoogleFonts.openSans(fontSize: 16),
              ),
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

class VisibilitySettingsWidget extends StatelessWidget {
  final bool isAllPublic;
  final bool isPrivate;
  final Set<FriendshipProgress> friendships;

  const VisibilitySettingsWidget({
    Key? key,
    required this.isAllPublic,
    required this.isPrivate,
    required this.friendships,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (BuildContext context) {
      Widget headerIcon;
      String message;

      if (isAllPublic) {
        headerIcon =
            Icon(Icons.public_rounded, color: Colors.green[900], size: 60);
        message = AppLocalizations.of(context)?.translate('vsd_public') ??
            'All your current friends will be able to view this picture.';
      } else if (isPrivate) {
        headerIcon = Icon(Icons.lock_rounded, color: Colors.red[900], size: 60);
        message = AppLocalizations.of(context)?.translate('vsd_private') ??
            'Only you and the friends in this picture can see it.';
      } else {
        List<FriendshipProgress> sortedFriendships = friendships.toList()
          ..sort((a, b) => a.friendUsername().compareTo(b.friendUsername()));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Align(
              alignment: Alignment.center,
              child: Icon(Icons.group_rounded, size: 35),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                AppLocalizations.of(context)?.translate('vsd_protected') ??
                    'These people will be able to see this picture:',
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: sortedFriendships.length,
                itemBuilder: (context, index) {
                  final friendship = sortedFriendships[index];
                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(
                      friendship.friendUsername(),
                      style: GoogleFonts.openSans(),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          headerIcon,
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: AutoSizeText(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(
                fontSize: isPrivate ? 18 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      );
    });
  }
}
