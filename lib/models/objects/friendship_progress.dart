import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utilities/constants.dart';
import '../data/data_manager.dart';

class FriendshipProgress {
  String user1;
  String user2;
  int level;
  double progress;
  String friendshipID;
  DateTime created;
  int index;
  bool isBestFriend = false;

  FriendshipProgress({
    required this.user1,
    required this.user2,
    required this.friendshipID,
    required this.level,
    required this.progress,
    required this.index,
    required this.created,
  });

  double strength() {
    return level + progress;
  }

  String friendId() {
    // If current user id is 0, then friend index is 1;
    if (index == 0) {
      return user2;
    }
    return user1;
  }

  factory FriendshipProgress.fromMap(
      Map<String, dynamic> map, String currentUserID) {
    int index;
    String user1 = map.containsKey(Constants.user1Doc)
        ? map[Constants.user1Doc]
        : 'FP_MISSING_USER1';
    String user2 = map.containsKey(Constants.user2Doc)
        ? map[Constants.user2Doc]
        : 'FP_MISSING_USER2';
    if (user1 == currentUserID) {
      index = 0;
    } else {
      index = 1;
    }

    return FriendshipProgress(
        index: index,
        user1: user1,
        user2: user2,
        level:
            map.containsKey(Constants.levelDoc) ? map[Constants.levelDoc] : 0,
        progress: map.containsKey(Constants.progressDoc)
            ? (map[Constants.progressDoc] as num).toDouble()
            : 0,
        friendshipID: user1 + user2,
        created: map.containsKey(Constants.createdDoc)
            ? (map[Constants.createdDoc] as Timestamp).toDate()
            : DateTime.now());
  }

  factory FriendshipProgress.fromDocs(
      DocumentSnapshot docs, String currentUserId) {
    String user1 = DataManager.getString(docs, Constants.user1Doc);
    int index;
    if (user1 == currentUserId) {
      index = 0;
    } else {
      index = 1;
    }
    return FriendshipProgress(
      index: index,
      friendshipID: docs.id,
      level: DataManager.getNumber(docs, Constants.levelDoc).toInt(),
      progress: DataManager.getNumber(docs, Constants.progressDoc).toDouble(),
      user1: user1,
      user2: DataManager.getString(docs, Constants.user2Doc),
      created: DataManager.getDateTime(docs, Constants.createdDoc),
    );
  }

  factory FriendshipProgress.newFriendship(
    String id1,
    String id2,
    String username1,
    String username2,
    int level,
    double progress,
    DateTime timestamp,
  ) {
    final List<String> ids = [id1, id2];
    ids.sort();

    if (id1 != ids.first) {
      String obj = username1;
      username1 = username2;
      username2 = obj;
    }

    // NO NEED TO REALLY SET AN INDEX NOW SINCE IT IS TO UPLOAD ON FIRESTORE
    String friendshipId = ids.join();
    return FriendshipProgress(
        index: 0,
        user1: ids.first,
        user2: ids.last,
        friendshipID: friendshipId,
        level: level,
        progress: progress,
        created: timestamp);
  }

  Map<String, dynamic> toMap() {
    return {
      Constants.user1Doc: user1,
      Constants.user2Doc: user2,
      Constants.levelDoc: level,
      Constants.progressDoc: progress,
      Constants.createdDoc: created
    };
  }

  @override
  String toString() {
    return 'FriendshipProgress{user1ID: $user1, user2ID: $user2, level: $level, progress: $progress, friendshipID: $friendshipID, index: $index}';
  }
}
