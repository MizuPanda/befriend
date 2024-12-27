import 'package:befriend/models/objects/friendship_progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'bubble.dart';

class Friendship extends FriendshipProgress {
  Bubble friend;

  Friendship._({
    required super.index,
    required super.user1,
    required super.user2,
    required super.friendshipID,
    required super.level,
    required super.progress,
    required super.created,
    required this.friend,
  });

  factory Friendship.fromDocs(
      String currentUserId, Bubble friendBubble, DocumentSnapshot docs) {
    FriendshipProgress friendshipProgress =
        FriendshipProgress.fromDocs(docs, currentUserId);

    return Friendship._(
      index: friendshipProgress.index,
      user1: friendshipProgress.user1,
      user2: friendshipProgress.user2,
      friendshipID: friendshipProgress.friendshipID,
      level: friendshipProgress.level,
      progress: friendshipProgress.progress,
      created: friendshipProgress.created,
      friend: friendBubble,
    );
  }

  factory Friendship.lockedFriendship(Bubble mainUser, Bubble friendBubble) {
    final List<String> ids = [friendBubble.id, mainUser.id];
    ids.sort();
    final int index;

    if (mainUser.id == ids.first) {
      index = 0;
    } else {
      index = 1;
    }

    return Friendship._(
        index: index,
        user1: ids.first,
        user2: ids.last,
        friendshipID: ids.first + ids.last,
        level: 0,
        progress: 0,
        created: DateTime.now(),
        friend: friendBubble);
  }

  double distance() {
    if (level + progress == 0) {
      return 150;
    }
    return 150 / (level.toDouble() + progress);
  }
}
