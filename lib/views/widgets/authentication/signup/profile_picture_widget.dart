import 'package:auto_size_text/auto_size_text.dart';
import 'package:befriend/providers/sign_provider.dart';
import 'package:befriend/utilities/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../utilities/constants.dart';

class ProfilePictureWidget extends StatelessWidget {
  const ProfilePictureWidget({super.key});

  static const double _avatarLengthMultiplier = 0.25;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool lightMode = Theme.of(context).brightness == Brightness.light;

    return Consumer<SignProvider>(
        builder: (BuildContext context, SignProvider provider, Widget? child) {
      return SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            // The circular profile picture container:
            Container(
              width: width * _avatarLengthMultiplier,
              height: width * _avatarLengthMultiplier,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  width: 1,
                  color: lightMode ? Colors.black : Colors.white,
                ),
              ),
              child: CircleAvatar(
                radius: width * _avatarLengthMultiplier,
                backgroundImage: provider.imageNull()
                    ? Image.asset(Constants.defaultPictureAddress).image
                    : provider.image(),
              ),
            ),
            // The Capture Photo button:
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () async {
                    await provider.retrieveImage(context);
                  },
                  child: AutoSizeText(
                    AppLocalizations.translate(
                      context,
                      key: 'ppw_capture',
                      defaultString: 'Capture Photo',
                    ),
                  ),
                ),
                TextButton(
                  onPressed: provider.imageNull()
                      ? null
                      : () async {
                          await provider.removeImage();
                        },
                  child: AutoSizeText(
                    AppLocalizations.translate(
                      context,
                      key: 'ppw_remove',
                      defaultString: 'Remove Photo',
                    ),
                    style: provider.imageNull()
                        ? null
                        : const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
