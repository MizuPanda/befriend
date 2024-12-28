import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/objects/bubble.dart';
import '../../../utilities/app_localizations.dart';

class UsernameText extends StatelessWidget {
  const UsernameText({
    super.key,
    required this.user,
    required this.isBestFriend,
  });

  final Bubble user;
  final bool isBestFriend;

  @override
  Widget build(BuildContext context) {
    double iconSize = 24 / 84 * user.size;

    return Row(
      children: [
        AutoSizeText(
            user.main()
                ? AppLocalizations.translate(context,
                    key: 'general_word_you', defaultString: 'You')
                : user.username,
            maxLines: 1,
            style: GoogleFonts.openSans(
                fontWeight: user.main() ? FontWeight.w300 : FontWeight.w500,
                fontStyle: user.main() ? FontStyle.italic : FontStyle.normal,
                fontSize: 27 / 117 * user.size)),
        if (isBestFriend)
          Stack(
            alignment: Alignment.center,
            children: [
              // Optional Shadow Effect
              Positioned(
                top: 0.5,
                left: 0.5,
                child: Icon(
                  Icons.star_rounded,
                  size: iconSize,
                  color: Colors.black.withOpacity(0.5),
                ),
              ),

              // Yellow Star on top
              Icon(
                Icons.star_rounded,
                size: iconSize,
                color: Colors.yellowAccent,
              ),
            ],
          )
      ],
    );
  }
}
