import 'package:befriend/models/objects/friendship.dart';
import 'package:befriend/providers/home_provider.dart';
import 'package:befriend/views/widgets/home/bubble/shakeable_bubble.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../../models/objects/home.dart';

class BubbleGroupWidget extends StatelessWidget {
  const BubbleGroupWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
        builder: (BuildContext context, HomeProvider provider, Widget? child) {
      return Stack(
        children: [
          ShakeableBubble(
            specificHome: provider.home,
          ),
          for (Friendship friendship in provider.home.user().friendships)
            Transform.translate(
                offset: Offset(friendship.friend.x, friendship.friend.y),
                child: Builder(builder: (context) {
                  if (friendship.friend.main()) {
                    return ShakeableBubble(
                        specificHome: Home.fromUser(friendship.friend));
                  }
                  return ShakeableBubble(
                      specificHome: Home.fromFriendship(friendship));
                }))
        ],
      );
    });
  }
}
