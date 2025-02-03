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
  int streak;
  DateTime lastInteraction;

  FriendshipProgress(
      {required this.user1,
      required this.user2,
      required this.friendshipID,
      required this.level,
      required this.progress,
      required this.index,
      required this.created,
      required this.streak,
      required this.lastInteraction});

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

  static String _getString(Map<String, dynamic> map, String id) {
    return map.containsKey(id) ? map[id] : '';
  }

  static num _getNumber(Map<String, dynamic> map, String id) {
    return map.containsKey(id) ? map[id] : 0;
  }

  static DateTime _getDateTime(Map<String, dynamic> map, String id) {
    return map.containsKey(id)
        ? (map[id] as Timestamp).toDate()
        : DateTime.now();
  }

  factory FriendshipProgress.fromMap(
      Map<String, dynamic> map, String currentUserID) {
    int index;
    String user1 = _getString(map, Constants.user1Doc);
    String user2 = _getString(map, Constants.user2Doc);

    if (user1 == currentUserID) {
      index = 0;
    } else {
      index = 1;
    }

    return FriendshipProgress(
        index: index,
        user1: user1,
        user2: user2,
        level: _getNumber(map, Constants.levelDoc).toInt(),
        progress: _getNumber(map, Constants.progressDoc).toDouble(),
        friendshipID: user1 + user2,
        created: _getDateTime(map, Constants.createdDoc),
        streak: _getNumber(map, Constants.streakDoc).toInt(),
        lastInteraction: _getDateTime(map, Constants.lastInteractionDoc));
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
        streak: DataManager.getNumber(docs, Constants.streakDoc).toInt(),
        lastInteraction:
            DataManager.getDateTime(docs, Constants.lastInteractionDoc));
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
        created: timestamp,
        streak: 1,
        lastInteraction: timestamp);
  }

  @override
  String toString() {
    return 'FriendshipProgress{user1ID: $user1, user2ID: $user2, level: $level, progress: $progress, friendshipID: $friendshipID, index: $index}';
  }
}
