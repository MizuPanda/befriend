import 'dart:math';

import '../views/widgets/home/bubble/bubble_widget.dart';
import 'bubble.dart';
import 'friendship.dart';

class Home {
  final Bubble user;
  final bool connectedHome;

  Home({required this.user, required this.connectedHome});

  void initializePositions() {
    Bubble main = user;
    Random rand = Random();

    for (Friendship friendship in user.friendships) {
      Bubble b = friendship.friendBubble;
      b.x = rand.nextDouble() * friendship.distance(); // x=6
      b.y = sqrt(
          pow(friendship.distance(), 2) - pow(b.x, 2)); //100 - 36 = 64, y = 8

      b.x += (main.size + b.size / 2) / 2 + BubbleWidget.textHeight;
      b.y += (main.size + b.size / 2) / 2 + BubbleWidget.textHeight;

      if (rand.nextBool()) {
        b.x *= -1;
      }
      if (rand.nextBool()) {
        b.y *= -1;
      }
    }
    _avoidOverlapping();
  }

  void _avoidOverlapping() {
    bool overlapping = true;

    user.friendships.sort((a, b) => a.distance().compareTo(b.distance()));
    while (overlapping) {
      overlapping = false;
      for (var i = 0; i < user.friendships.length; i++) {
        final bubble = user.friendships[i].friendBubble;

        for (var j = i + 1; j < user.friendships.length; j++) {
          final otherBubble = user.friendships[j].friendBubble;
          final dx = otherBubble.x - bubble.x;
          final dy = otherBubble.y - bubble.y;
          final distance = otherBubble.point().distanceTo(bubble.point());
          final force = bubble.size * otherBubble.size / (distance * distance);

          if (distance < bubble.size + otherBubble.size) {
            overlapping = true;

            otherBubble.x += (dx / distance) * force;
            otherBubble.y += (dy / distance) * force;
          }
        }
      }
    }
  }
}
