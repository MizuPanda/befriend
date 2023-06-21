import 'package:flutter/material.dart';

import '../utilities/randomizer.dart';

class Bubble {
  final String username;
  final String name;
  List<Friendship> friendships;
  late int level;
  late double size;
  double x = 0;
  double y = 0;
  late ImageProvider avatar;
  late final Gradient gradient;

  Bubble(
      {required this.username,
        required this.name,
        required this.friendships,}) {
    avatar = const NetworkImage('https://picsum.photos/200');
    gradient = Randomizer.linearGradient();
    initializeLevel();
  }

  void initializeLevel() {
    level = 0;
    for(Friendship friendship in friendships) {
      level += friendship.level;
    }

    size = 40 + level*55/12;
  }
}

class Friendship {
  Bubble friendBubble;
  int level;
  double progress;
  int newPics;

  Friendship({required this.friendBubble, required this.level, required this.progress, required this.newPics});

  double distance() {
      return 150 / (level + progress / 100);
  }
}



