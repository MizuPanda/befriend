import 'package:befriend/views/pages/profile_page.dart';
import 'package:befriend/views/widgets/users/profile_photo.dart';
import 'package:befriend/views/widgets/users/username_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/bubble_user.dart';
import 'bubble_progress_indicator.dart';

class BubbleWidget extends StatelessWidget {
  final BubbleUser user;
  static const double strokeWidth = 4.33;
  static const double textHeight = 25;
  static const double levelHeight = 25;
  const BubbleWidget({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ProfilePage(user: user)));
      },
      child: Center(
        child: Container(
          color: Colors.red,
          height: user.bubble().size + textHeight,
          child: Builder(builder: (context) {
            if (!user.main && user.friendship != null) {
              return Badge(
                label: Text(
                  user.friendship!.newPics.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                largeSize: 25,
                offset: const Offset(0, 0),
                padding: const EdgeInsets.only(left: 7, right: 7),
                isLabelVisible: user.friendship!.newPics > 0 && !user.main,
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Stack(children: [
                          BubbleContainer(user: user),
                          if (!user.main)
                            BubbleProgressIndicator(
                                friendship: user.friendship!),
                          BubbleGradientIndicator(friendship: user.friendship!),
                        ]),
                        UsernameText(user: user),
                      ],
                    ),
                    if (!user.main)
                      Container(
                        width: user.bubble().size,
                        padding: EdgeInsets.only(
                            bottom: textHeight - levelHeight + 30 / 2,
                            left: user.bubble().size / 2),
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          user.friendship!.level.toString(),
                          style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: levelHeight/(1 + user.bubble().size/(user.bubble().size*7)),
                            shadows: const [
                              Shadow(
                                offset: Offset.zero,
                                blurRadius: 15.0,
                                color: Colors.black,
                              ),
                            ],
                          )),
                        ),
                      )
                  ],
                ),
              );
            } else if (user.main && user.mainBubble != null) {
              //Main Bubble
              return SizedBox(
                height: user.mainBubble!.size + textHeight,
                child: Column(
                  children: [
                    BubbleContainer(user: user),
                    UsernameText(
                      user: user,
                    ),
                  ],
                ),
              );
            } else {
              return const Center(
                child: Text('Error - Bubble Widget'),
              );
            }
          }),
        ),
      ),
    );
  }
}

class BubbleContainer extends StatelessWidget {
  const BubbleContainer({
    super.key,
    required this.user,
  });

  final BubbleUser user;

  @override
  Widget build(BuildContext context) {
    return ProfilePhoto(user: user);
  }
}
