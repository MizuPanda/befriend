import 'package:befriend/models/objects/friendship.dart';
import 'package:befriend/providers/home_provider.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:befriend/views/widgets/home/bubble/shakeable_bubble.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/objects/home.dart';

class BubbleGroupWidget extends StatelessWidget {
  const BubbleGroupWidget({
    Key? key,
  }) : super(key: key);

  static double widthCentered(BuildContext context,
      {required double size, required double dx}) {
    double halfWidth = MediaQuery.of(context).size.width / 2;

    return halfWidth - size / 2 + dx + Constants.viewerSize / 2;
  }

  static double heightCentered(BuildContext context,
      {required double bubbleHeight, required double dy}) {
    double halfHeight = MediaQuery.of(context).size.height / 2;

    return halfHeight - bubbleHeight / 2 + dy + Constants.viewerSize / 2;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
        builder: (BuildContext context, HomeProvider provider, Widget? child) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          // This assumes ShakeableBubble does not require dynamic positioning.
          // If it does, consider wrapping it with a Positioned widget as well.
          Positioned(
            left: widthCentered(context, size: provider.home.user.size, dx: 0),
            top: heightCentered(context,
                bubbleHeight: provider.home.user.bubbleHeight(), dy: 0),
            child: ShakeableBubble(
              specificHome: provider.home,
            ),
          ),
          ...provider.home.user.friendships
              .where((friend) => !friend.friend.didBlockYou())
              .map((Friendship friendship) {
            return Positioned(
              left: widthCentered(context,
                  size: friendship.friend.size, dx: friendship.friend.x),
              top: heightCentered(context,
                  bubbleHeight: friendship.friend.bubbleHeight(),
                  dy: friendship.friend.y),
              child: Builder(builder: (context) {
                // Checking if the friend is the main user is preserved from your original implementation.
                if (friendship.friend.main()) {
                  return ShakeableBubble(
                      specificHome: Home.fromUser(friendship.friend));
                } else {
                  // No need for Size calculations here, since we're using Positioned.
                  return ShakeableBubble(
                      specificHome: Home.fromFriendship(friendship));
                }
              }),
            );
          }).toList(),
        ],
      );
    });
  }
}
