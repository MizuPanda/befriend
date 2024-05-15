import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utilities/constants.dart';
import '../data/data_manager.dart';

class FriendshipProgress {
  String user1;
  String user2;
  String username1;
  String username2;
  int level;
  double progress;
  String friendshipID;
  DateTime lastSeen;
  int index;

  FriendshipProgress({
    required this.user1,
    required this.user2,
    required this.username1,
    required this.username2,
    required this.friendshipID,
    required this.level,
    required this.progress,
    required this.lastSeen,
    required this.index,
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

  String friendUsername() {
    // If current user id is 0, then friend index is 1;
    if (index == 0) {
      return username2;
    }
    return username1;
  }

  factory FriendshipProgress.fromMap(
      Map<String, dynamic> map, String currentUserID) {
    int index;
    String user1 = map[Constants.user1Doc];
    if (user1 == currentUserID) {
      index = 0;
    } else {
      index = 1;
    }

    return FriendshipProgress(
      index: index,
      user1: user1,
      user2: map[Constants.user2Doc] as String,
      username1: map[Constants.username1Doc] as String,
      username2: map[Constants.username2Doc] as String,
      level: map[Constants.levelDoc] as int,
      progress: (map[Constants.progressDoc] as num).toDouble(),
      lastSeen: (map.containsKey(Constants.lastSeenDoc)
          ? (map[Constants.lastSeenDoc] as Timestamp).toDate()
          : DateTime.utc(0)),
      friendshipID: (map[Constants.user1Doc] as String) +
          (map[Constants.user2Doc] as String),
    );
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
      username1: DataManager.getString(docs, '${Constants.usernameDoc}1'),
      username2: DataManager.getString(docs, '${Constants.usernameDoc}2'),
      level: DataManager.getNumber(docs, Constants.levelDoc).toInt(),
      progress: DataManager.getNumber(docs, Constants.progressDoc).toDouble(),
      lastSeen: DataManager.getDateTime(docs, Constants.lastSeenDoc),
      user1: user1,
      user2: DataManager.getString(docs, Constants.user2Doc),
    );
  }

  factory FriendshipProgress.newFriendship(
      String id1,
      String id2,
      String username1,
      String username2,
      int level,
      double progress,
      DateTime timestamp) {
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
        username1: username1,
        username2: username2,
        friendshipID: friendshipId,
        level: level,
        progress: 0,
        lastSeen: timestamp);
  }

  Map<String, dynamic> toMap() {
    return {
      Constants.user1Doc: user1,
      Constants.user2Doc: user2,
      Constants.username1Doc: username1,
      Constants.username2Doc: username2,
      Constants.levelDoc: level,
      Constants.progressDoc: progress,
      Constants.lastSeenDoc: lastSeen,
    };
  }

  @override
  String toString() {
    return 'FriendshipProgress{user1ID: $user1, user2ID: $user2, username1: $username1, username2: $username2, level: $level, progress: $progress, friendshipID: $friendshipID, lastSeen: $lastSeen, index: $index}';
  }
}
