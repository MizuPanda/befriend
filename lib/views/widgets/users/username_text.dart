import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/objects/bubble.dart';
import '../home/bubble/bubble_widget.dart';

class UsernameText extends StatelessWidget {
  const UsernameText({
    super.key,
    required this.user,
  });

  final Bubble user;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: BubbleWidget.textHeight,
      child: Text(user.main() ? 'You' : user.username,
          style: GoogleFonts.robotoCondensed(
            textStyle: TextStyle(
              color: Colors.black,
              fontWeight: user.main() ? FontWeight.w300 : FontWeight.w500,
              fontStyle: user.main() ? FontStyle.italic : FontStyle.normal,
              fontSize: 20,
            ),
          )),
    );
  }
}
