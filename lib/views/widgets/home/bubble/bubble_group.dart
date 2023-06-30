import 'package:befriend/providers/home_provider.dart';
import 'package:befriend/views/widgets/home/bubble/shakeable_bubble.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../../models/friendship.dart';
import '../../../../models/home.dart';

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
          for (Friendship friendship in provider.home.user.friendships)
            Transform.translate(
                offset: Offset(
                    friendship.friendBubble.x, friendship.friendBubble.y),
                child: ShakeableBubble(
                    specificHome: Home(
                        user: friendship.friendBubble,
                        connectedHome: friendship.friendBubble.main())))
        ],
      );
    });
  }
}
