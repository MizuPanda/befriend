import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../models/friendship.dart';
import '../../../../models/home.dart';

class FriendLevelWidget extends StatelessWidget {
  const FriendLevelWidget({
    super.key,
    required this.specificHome,
    required this.textHeight,
    required this.levelHeight,
    required this.friendship,
  });

  final Home specificHome;
  final double textHeight;
  final double levelHeight;
  final Friendship friendship;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: specificHome.user().size,
      padding: EdgeInsets.only(
          bottom: textHeight - levelHeight + 30 / 2,
          left: specificHome.user().size / 2),
      alignment: Alignment.bottomCenter,
      child: Text(
        friendship.level.toString(),
        style: GoogleFonts.montserrat(
            textStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: levelHeight /
              (1 + specificHome.user().size / (specificHome.user().size * 7)),
          shadows: const [
            Shadow(
              offset: Offset.zero,
              blurRadius: 15.0,
              color: Colors.black,
            ),
          ],
        )),
      ),
    );
  }
}
