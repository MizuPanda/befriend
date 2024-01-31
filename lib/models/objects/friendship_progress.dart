import 'package:befriend/models/authentication/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utilities/constants.dart';
import '../data/data_manager.dart';

class FriendshipProgress {
  String user1ID;
  String user2ID;
  String username1;
  String username2;
  int level;
  double progress;
  String friendshipID;
  DateTime lastSeen;
  int index;

  FriendshipProgress({
    required this.user1ID,
    required this.user2ID,
    required this.username1,
    required this.username2,
    required this.friendshipID,
    required this.level,
    required this.progress,
    required this.lastSeen,
    required this.index,
});

  String friendId() {
    if (index == 0) {
      return user2ID;
    }
    return user1ID;
  }

  String friendUsername() {
    if(index == 0) {
      return username2;
    }
    return username1;
  }

  factory FriendshipProgress.fromMap(Map<String, dynamic> map) {
    int index;
    if (map['${Constants.userDoc}1'] as String == AuthenticationManager.id()) {
      index = 0;
    } else {
      index = 1;
    }

    return FriendshipProgress(
      index: index,
      user1ID: map['${Constants.userDoc}1'] as String,
      user2ID: map['${Constants.userDoc}2'] as String,
      username1: map['${Constants.usernameDoc}1'] as String,
      username2: map['${Constants.usernameDoc}2'] as String,
      level: map[Constants.levelDoc] as int,
      progress: (map[Constants.progressDoc] as num).toDouble(),
      lastSeen: (map[Constants.lastSeenDoc] as Timestamp).toDate(),
      friendshipID: (map['${Constants.userDoc}1'] as String) + map['${Constants.userDoc}2'],
    );
  }


  factory FriendshipProgress.fromDocs(DocumentSnapshot docs) {
    String user1ID = DataManager.getString(docs, '${Constants.userDoc}1');
    int index;
    if(user1ID == AuthenticationManager.id()) {
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
      user1ID: DataManager.getString(docs, '${Constants.userDoc}1'),
      user2ID: DataManager.getString(docs, '${Constants.userDoc}2'),
    );
  }

  factory FriendshipProgress.newFriendship(String id1, String id2, String username1, String username2, int level, double progress, DateTime timestamp) {
    final List<String> ids = [id1, id2];
    ids.sort();
    int index;
    if (AuthenticationManager.id() == ids.first) {
      index = 0;
    } else {
      index = 1;
    }
    String friendshipId = ids.join();
    return FriendshipProgress(
      index: index,
        user1ID: id1,
        user2ID: id2,
        username1: username1,
        username2: username2,
        friendshipID: friendshipId,
        level: level,
        progress: 0,
        lastSeen: timestamp);
  }

  Map<String, dynamic> toMap() {
    List<String> ids = [user1ID, user2ID];
    ids.sort();
    return {
      '${Constants.userDoc}1': ids.first,
      '${Constants.userDoc}2': ids.last,
      '${Constants.usernameDoc}1': username1,
      '${Constants.usernameDoc}2': username2,
      Constants.levelDoc: level,
      Constants.progressDoc: progress,
      Constants.lastSeenDoc: lastSeen,
    };
  }
}
