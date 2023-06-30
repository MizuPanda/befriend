import 'dart:math';

import 'package:befriend/utilities/samples.dart';
import 'package:flutter/material.dart';

import 'friendship.dart';

class Bubble {
  final String username;
  final String name;
  List<Friendship> friendships;
  late int level;
  late double size;
  double x = 0;
  double y = 0;
  late ImageProvider avatar;
  final Gradient gradient = const RadialGradient(
    colors: [Colors.green, Colors.lightGreenAccent],
  );

  static final Bubble _juniel = BubbleSample.connectedUser;

  Bubble({
    required this.username,
    required this.name,
    required this.friendships,
  }) {
    avatar = const NetworkImage('https://picsum.photos/200');

    initializeLevel();
  }

  bool main() {
    return this == _juniel;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Bubble &&
          runtimeType == other.runtimeType &&
          username == other.username;

  @override
  int get hashCode => username.hashCode;

  Friendship? friendship() {
    if (!main()) {
      for (Friendship friend in _juniel.friendships) {
        if (friend.friendBubble == this) {
          return friend;
        }
      }
    }

    return null;
  }

  String levelText() {
    return main() ? 'Social Level' : 'Relationship Level';
  }

  String levelNumberText() {
    if (main()) {
      return level.toString();
    } else {
      return _juniel.friendships
          .firstWhere((friendship) => friendship.friendBubble == this)
          .level
          .toString();
    }
  }

  void initializeLevel() {
    level = friendships.fold(0, (sum, friendship) => sum + friendship.level);

    size = 40 + level * 55 / 12;
  }

  Point<double> point() {
    return Point(x, y);
  }
}
