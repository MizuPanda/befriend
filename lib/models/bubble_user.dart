import 'bubble.dart';

class BubbleUser {
  final bool main;
  Bubble? mainBubble;
  Friendship? friendship;

  BubbleUser({required this.main, this.mainBubble, this.friendship});

  Bubble bubble() {
    return main? mainBubble!: friendship!.friendBubble;
  }

  String levelText() {
    return main? 'Social Level' : 'Relationship Level';
  }
  String levelNumberText() {
    return '${main? mainBubble!.level : friendship!.level}';
  }
}