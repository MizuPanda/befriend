import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/objects/bubble.dart';
import '../../../utilities/app_localizations.dart';

class UsernameText extends StatelessWidget {
  const UsernameText({
    super.key,
    required this.user,
  });

  final Bubble user;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: AutoSizeText(user.main() ? AppLocalizations.of(context)?.translate('general_word_you')??'You' : user.username,
          maxLines: 1,
          style: GoogleFonts.openSans(
              fontWeight: user.main() ? FontWeight.w300 : FontWeight.w500,
              fontStyle: user.main() ? FontStyle.italic : FontStyle.normal,
              fontSize: 27 / 117 * user.size)),
    );
  }
}
