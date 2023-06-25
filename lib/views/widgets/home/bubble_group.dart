import 'package:flutter/cupertino.dart';

import '../../../models/bubble.dart';
import '../../pages/home_page.dart';
import '../bubble_widget.dart';

class BubbleGroupWidget extends StatelessWidget {
  const BubbleGroupWidget({
    super.key,
    required this.widget,
    required List<Friendship> friendships,
  }) : _friendships = friendships;

  final HomePage widget;
  final List<Friendship> _friendships;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ShakeableBubble(
          user: widget.user,
          connectedHome: widget.connectedHome,

        ),
        for (Friendship friendship in _friendships)
          Transform.translate(
            offset:
                Offset(friendship.friendBubble.x, friendship.friendBubble.y),
            child: ShakeableBubble(
                user: friendship.friendBubble,
                connectedHome: widget.connectedHome,
          )
          )
      ],
    );
  }
}
