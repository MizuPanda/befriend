import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../models/objects/friendship.dart';
import '../../../../models/objects/home.dart';

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
      width: specificHome.user.size,
      padding: EdgeInsets.only(
          bottom: textHeight - levelHeight + 30 / 2,
          left: specificHome.user.size / 2),
      alignment: Alignment.bottomCenter,
      child: Text(
        friendship.level.toString(),
        style: GoogleFonts.openSans(
            textStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: levelHeight /
              (1 + specificHome.user.size / (specificHome.user.size * 8)),
          shadows: const [
            Shadow(
              offset: Offset.zero,
              blurRadius: 8.0,
              color: Colors.black,
            ),
          ],
        )),
      ),
    );
  }
}
