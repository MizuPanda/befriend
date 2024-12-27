
import 'package:befriend/models/data/data_manager.dart';
import 'package:befriend/models/objects/friendship.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../authentication/authentication.dart';

class Bubble {
  final String id;
  final String username;
  final String avatarUrl;
  final int power;
  ImageProvider avatar;
  final int birthYear;
  String languageCode;

  List<dynamic> blockedUsers;

  Map<String, DateTime> lastSeenUsersMap;

  List<Friendship> friendships = [];
  List<dynamic> friendIDs;
  bool friendshipsLoaded = false;

  bool postNotificationOn;
  bool likeNotificationOn;

  String bestFriendID = '';
  //-----------------------
  double size;
  double x = 0;
  double y = 0;

  Function notify = () {};

  Bubble._({
    required this.id,
    required this.username,
    required this.power,
    required this.birthYear,
    required this.size,
    required this.avatar,
    required this.avatarUrl,
    required this.lastSeenUsersMap,
    required this.friendIDs,
    required this.blockedUsers,
    required this.postNotificationOn,
    required this.likeNotificationOn,
    required this.languageCode,
  });

  factory Bubble.fromDocs(
    DocumentSnapshot docs,
    ImageProvider avatar,
  ) {
    int pwr = DataManager.getNumber(docs, Constants.powerDoc).toInt();

    double size = 60 + pwr * 11 / 3;

    Bubble bubble = Bubble._(
        id: docs.id,
        username: DataManager.getString(docs, Constants.usernameDoc),
        power: pwr,
        birthYear: DataManager.getNumber(docs, Constants.birthYearDoc).toInt(),
        size: size,
        avatarUrl: DataManager.getString(docs, Constants.avatarDoc),
        lastSeenUsersMap:
            DataManager.getDateTimeMap(docs, Constants.lastSeenUsersMapDoc),
        friendIDs: DataManager.getList(docs, Constants.friendsDoc),
        blockedUsers: DataManager.getList(docs, Constants.blockedUsersDoc),
        postNotificationOn:
            DataManager.getBoolean(docs, Constants.postNotificationOnDoc),
        likeNotificationOn:
            DataManager.getBoolean(docs, Constants.likeNotificationOnDoc),
        languageCode: DataManager.getString(docs, Constants.languageDoc),
        avatar: avatar,
    );

    return bubble;
  }

  bool main() {
    return id == AuthenticationManager.id();
  }

  bool hasFriends() {
    return friendships.isNotEmpty;
  }

  bool didBlockYou() {
    return blockedUsers.contains(AuthenticationManager.id());
  }

  Iterable<dynamic> nonLoadedFriends() {
    if (friendships.isEmpty) {
      return friendIDs;
    }
    Iterable<String> friends =
        friendships.map((friendship) => friendship.friendId());

    return friendIDs.where((id) => !friends.contains(id));
  }

  bool hasNonLoadedFriends() {
    return friendIDs.length > friendships.length;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Bubble && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Bubble{id: $id, username: $username, avatarUrl: $avatarUrl, power: $power, friendIDs: $friendIDs, friendshipsLoaded: $friendshipsLoaded,}';
  }
}
