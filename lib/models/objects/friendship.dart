import 'package:befriend/models/objects/friendship_progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'bubble.dart';

class Friendship extends FriendshipProgress {
  Bubble friend;

  Friendship._({
    required super.index,
    required super.user1ID,
    required super.user2ID,
    required super.friendshipID,
    required super.username1,
    required super.username2,
    required super.level,
    required super.progress,
    required super.lastSeen,
    required this.friend,
  });

  Friendship swap(Bubble friendBubble, String id, Friendship f) {
    f.switchIndex();

    return switchBubble(friendBubble, f);
  }

  Friendship switchBubble(Bubble friendBubble, Friendship f) {
    return Friendship._(
      index: f.index,
      user1ID: f.user1ID,
      user2ID: f.user2ID,
      friendshipID: f.friendshipID,
      username1: f.username1,
      username2: f.username2,
      level: f.level,
      progress: f.progress,
      lastSeen: f.lastSeen,
      friend: friendBubble,
    );
  }

  factory Friendship.custom(
    int index,
    String user1ID,
    String user2ID,
    String friendshipID,
    String username1,
    String username2,
    int level,
    double progress,
    DateTime lastSeen,
    int numberOfPicsNotSeen,
    Bubble friend,
  ) {
    Friendship friendship = Friendship._(
      index: index,
      user1ID: user1ID,
      user2ID: user2ID,
      friendshipID: friendshipID,
      username1: username1,
      username2: username2,
      level: level,
      progress: progress,
      lastSeen: lastSeen,
      friend: friend,
    );

    return friendship;
  }

  factory Friendship.fromDocs(Bubble friendBubble, DocumentSnapshot docs) {
    FriendshipProgress friendshipProgress = FriendshipProgress.fromDocs(docs);

    return Friendship._(
      index: friendshipProgress.index,
      user1ID: friendshipProgress.user1ID,
      user2ID: friendshipProgress.user2ID,
      friendshipID: friendshipProgress.friendshipID,
      username1: friendshipProgress.username1,
      username2: friendshipProgress.username2,
      friend: friendBubble,
      level: friendshipProgress.level,
      progress: friendshipProgress.progress,
      lastSeen: friendshipProgress.lastSeen,
    );
  }

  static int setPicsSeen(Bubble bubble) {
    return 0;
  }

  double distance() {
    return 150 / (level.toDouble() + progress / 100);
  }
}
