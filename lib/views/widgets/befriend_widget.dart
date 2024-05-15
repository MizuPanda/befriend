import 'package:auto_size_text/auto_size_text.dart';
import 'package:befriend/models/data/user_manager.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../models/objects/bubble.dart';

class BefriendWidget extends StatelessWidget {
  const BefriendWidget({
    super.key,
    required this.five,
  });

  final GlobalKey five;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: GestureDetector(
            onTap: () async {
              Bubble user = await UserManager.getInstance();
              if (context.mounted) {
                GoRouter.of(context)
                    .push(Constants.friendListAddress, extra: user);
              }
            },
            child: Showcase(
                key: five,
                description: "Tap on 'Befriend' to open your friend list.",
                child: const BefriendTitle())),
      ),
    );
  }
}

class BefriendTitle extends StatelessWidget {
  const BefriendTitle({super.key, this.fontSize});

  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return AutoSizeText('Befriend',
        style: GoogleFonts.comingSoon(
          textStyle:
              TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize ?? 35),
        ));
  }
}
