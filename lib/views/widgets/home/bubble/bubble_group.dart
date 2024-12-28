import 'package:befriend/models/objects/friendship.dart';
import 'package:befriend/providers/home_provider.dart';
import 'package:befriend/views/widgets/home/bubble/shakeable_bubble.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../../models/objects/home.dart';
import '../../../../utilities/app_localizations.dart';

class BubbleGroupWidget extends StatelessWidget {
  const BubbleGroupWidget({
    super.key,
  });

  static double widthCentered(BuildContext context, double viewerSize,
      {required double size, required double dx}) {
    return (viewerSize / 2 + MediaQuery.of(context).size.width - size) / 2 + dx;
  }

  static double heightCentered(BuildContext context, double viewerSize,
      {required double bubbleHeight, required double dy}) {
    return (viewerSize / 2 +
                MediaQuery.of(context).size.height -
                bubbleHeight) /
            2 +
        dy;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
        builder: (BuildContext context, HomeProvider provider, Widget? child) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: widthCentered(context, provider.viewerSize,
                size: provider.home.user.size, dx: 0),
            top: heightCentered(context, provider.viewerSize,
                bubbleHeight: provider.home.user.size, dy: 0),
            child: Showcase(
              key: provider.two,
              descriptionAlignment: TextAlign.center,
              description: AppLocalizations.translate(context,
                  key: 'bg_two',
                  defaultString:
                      "Meet your friends in real life and take a picture together to add them to your friend list"),
              child: ShakeableBubble(
                specificHome: provider.home,
              ),
            ),
          ),
          ...provider.home.user.friendships
              .where((friend) => !friend.friend.didBlockYou())
              .map((Friendship friendship) {
            return Positioned(
              left: widthCentered(context, provider.viewerSize,
                  size: friendship.friend.size, dx: friendship.friend.x),
              top: heightCentered(context, provider.viewerSize,
                  bubbleHeight: friendship.friend.size,
                  dy: friendship.friend.y),
              child: ShakeableBubble(
                  specificHome: friendship.friend.main()
                      ? Home.fromUser(friendship.friend)
                      : Home.fromFriendship(friendship)),
            );
          }),
        ],
      );
    });
  }
}
