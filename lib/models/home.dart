import 'dart:math';

import 'package:befriend/models/friendship.dart';

import '../views/widgets/home/bubble/bubble_widget.dart';
import 'bubble.dart';

class Home {
  late Bubble? main;
  late Friendship? friendship;
  final bool connectedHome;

  Home({required this.connectedHome, required this.main, required this.friendship});

  factory Home.fromUser(Bubble user) {
    return Home(connectedHome: true, main: user, friendship: null);
  }

  factory Home.fromFriendship(Friendship friendship) {
    return Home(connectedHome: false, main: null, friendship: friendship);
  }
  Bubble user() {
    if(connectedHome) {
      return main!;
    }
    return friendship!.friend;
  }
  void initializePositions() {
    Bubble main = user();
    Random rand = Random();

    for (Friendship friendship in main.friendships) {
      Bubble friend = friendship.friend;
      friend.x = rand.nextDouble() * friendship.distance(); // x=6
      friend.y = sqrt(
          pow(friendship.distance(), 2) - pow(friend.x, 2)); //100 - 36 = 64, y = 8

      friend.x += (main.size + friend.size / 2) / 2 + BubbleWidget.textHeight;
      friend.y += (main.size + friend.size / 2) / 2 + BubbleWidget.textHeight;

      if (rand.nextBool()) {
        friend.x *= -1;
      }
      if (rand.nextBool()) {
        friend.y *= -1;
      }
    }

    _avoidOverlapping();
  }

  void _avoidOverlapping() {
    bool overlapping = true;
    
    Bubble homeUser = user();
    homeUser.friendships.sort((a, b) => a.distance().compareTo(b.distance()));
    while (overlapping) {
      overlapping = false;
      for (var i = 0; i < homeUser.friendships.length; i++) {
        final bubble = homeUser.friendships[i].friend;

        for (var j = i + 1; j < homeUser.friendships.length; j++) {
          final otherBubble = homeUser.friendships[j].friend;
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
