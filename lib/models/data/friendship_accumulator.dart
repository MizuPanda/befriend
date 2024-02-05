import '../objects/bubble.dart';
import '../objects/friendship.dart';

class FriendshipAccumulator {
  static final FriendshipAccumulator _singleton = FriendshipAccumulator._internal();
  final Set<Friendship> _savedFriendships = {};

  factory FriendshipAccumulator() {
    return _singleton;
  }

  Friendship? containsFriendship(String id1, String id2, Bubble bubble) {
    Friendship? friendship;
    for (Friendship f in _savedFriendships) {
      if (f.user1ID == id1 && f.user2ID == id2) {
        friendship = f.switchBubble(bubble, f);
        break;
      } else if (f.user1ID == id2 && f.user2ID == id1) {
        friendship = f.swap(bubble, id1, f);
        break;
      }
    }

    return friendship;
  }

  void refreshAccumulator() {
    _savedFriendships.clear();
  }

  void addFriendship(Friendship friendship) {
    _savedFriendships.add(friendship);
  }

  FriendshipAccumulator._internal();
}