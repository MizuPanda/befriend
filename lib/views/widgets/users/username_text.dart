import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/objects/bubble.dart';

class UsernameText extends StatelessWidget {
  const UsernameText({
    super.key,
    required this.user,
  });

  final Bubble user;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: user.textHeight(),
      width: user.size,
      alignment: Alignment.center,
      child: AutoSizeText(user.main() ? 'You' : user.username,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.openSans(
            textStyle: TextStyle(
                color: Colors.black,
                fontWeight: user.main() ? FontWeight.w300 : FontWeight.w500,
                fontStyle: user.main() ? FontStyle.italic : FontStyle.normal,
                fontSize: 30),
          )),
    );
  }
}
