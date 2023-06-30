import 'bubble.dart';

class Friendship {
  Bubble friendBubble;
  int level;
  double progress;
  int newPics;

  Friendship(
      {required this.friendBubble,
      required this.level,
      required this.progress,
      required this.newPics});

  double distance() {
    return 150 / (level.toDouble() + progress / 100);
  }
}
