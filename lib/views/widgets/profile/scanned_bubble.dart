import '../../../models/objects/bubble.dart';

class ScannedBubble {
  Bubble bubble;
  List<dynamic> friendsID;
  late bool alreadyFriend;

  ScannedBubble({
    required this.bubble,
    required this.friendsID}) {
    alreadyFriend = !(friendsID.every((friendId) => friendId != bubble.id));
  }
}