import 'package:befriend/models/objects/friendship_progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'bubble.dart';

class Friendship extends FriendshipProgress{
  Bubble friend;
  int numberOfPicsNotSeen;

  Friendship._(
      {
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
        required this.numberOfPicsNotSeen,});



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
      numberOfPicsNotSeen: setPicsSeen(friendBubble), //CALCULATE FROM BUBBLE (PICTURE SUB COLLECTION)
    );
  }



  static int setPicsSeen(Bubble bubble) {
    return 0;
  }
  double distance() {
    return 150 / (level.toDouble() + progress / 100);
  }

}
