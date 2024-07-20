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
    required super.username1,
    required super.username2,
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
      username1: friendshipProgress.username1,
      username2: friendshipProgress.username2,
      level: friendshipProgress.level,
      progress: friendshipProgress.progress,
      created: friendshipProgress.created,
      friend: friendBubble,
    );
  }

  double distance() {
    if (level + progress == 0) {
      return 150;
    }
    return 150 / (level.toDouble() + progress);
  }
}
