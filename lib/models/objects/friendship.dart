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

  factory Friendship.lockedFriendship(Bubble mainUser, Bubble friendBubble) {
    final List<String> ids = [friendBubble.id, mainUser.id];
    ids.sort();
    final String username1;
    final String username2;
    final int index;

    if (mainUser.id == ids.first) {
      index = 0;
      username1 = mainUser.id;
      username2 = friendBubble.id;
    } else {
      index = 1;
      username1 = friendBubble.id;
      username2 = mainUser.id;
    }
    return Friendship._(
        index: index,
        user1: ids.first,
        user2: ids.last,
        friendshipID: ids.first + ids.last,
        username1: username1,
        username2: username2,
        level: 0,
        progress: 0,
        created: DateTime.now(),
        friend: friendBubble);
  }

  @override
  String friendUsername() {
    return friend.username;
  }

  @override
  String friendId() {
    return friend.id;
  }

  double distance() {
    if (level + progress == 0) {
      return 150;
    }
    return 150 / (level.toDouble() + progress);
  }
}
