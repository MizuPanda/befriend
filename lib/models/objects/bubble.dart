import 'dart:math';

import 'package:befriend/models/authentication/authentication.dart';
import 'package:befriend/models/data/data_manager.dart';
import 'package:befriend/models/objects/friendship.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Bubble {
  final String id;
  final String username;
  final String avatarUrl;
  final int power;
  ImageProvider avatar;
  final int birthYear;

  Map<String, dynamic> blockedUsers;

  Map<String, DateTime> lastSeenUsersMap;

  List<Friendship> friendships = [];
  List<dynamic> friendIDs;
  bool friendshipsLoaded;
  //-----------------------
  double size;
  double x = 0;
  double y = 0;

  final Gradient gradient = const LinearGradient(
    colors: [Color(0xFFFF5F6D), Color(0xFFFFC371)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

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
    required this.friendshipsLoaded,
    required this.blockedUsers,
  });

  factory Bubble.fromDocsWithFriends(
      DocumentSnapshot docs, ImageProvider avatar, List<Friendship> friends) {
    Bubble bubble = Bubble._fromDocs(docs, avatar, true);
    bubble.friendships = friends;

    return bubble;
  }

  factory Bubble.fromDocsWithoutFriends(
      DocumentSnapshot docs, ImageProvider avatar) {
    return Bubble._fromDocs(docs, avatar, false);
  }

  factory Bubble._fromDocs(
      DocumentSnapshot docs, ImageProvider avatar, bool friendshipsLoaded) {
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
        friendshipsLoaded: friendshipsLoaded,
        blockedUsers: DataManager.getMap(docs, Constants.blockedUsersDoc),
        avatar: avatar);

    return bubble;
  }

  bool main() {
    return id == AuthenticationManager.id();
  }

  bool didBlockYou() {
    return blockedUsers.keys.contains(AuthenticationManager.id());
  }

  Iterable<String> loadedFriendIds() {
    return friendships.map((e) => e.friendId());
  }

  Iterable<String> nonLoadedFriendIds() {
    final List<String> nonLoadedIds = [];
    final Iterable<String> loadedIds = loadedFriendIds();

    for (String friendID in friendIDs) {
      if (!loadedIds.contains(friendID)) {
        nonLoadedIds.add(friendID);
      }
    }

    return nonLoadedIds;
  }

  bool isFriendLoaded(String friendId) {
    return loadedFriendIds().contains(friendId);
  }

  bool hasNonLoadedFriends() {
    return friendIDs.length > friendships.length;
  }

  Future<DocumentSnapshot> getLastFriendshipDocument() async {
    return await Constants.friendshipsCollection
        .doc(friendships.last.friendshipID)
        .get();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Bubble && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  double textHeight() {
    return 5 / 12 * size;
  }

  double bubbleHeight() {
    return size + textHeight();
  }

  Point<double> point() {
    return Point(x, y);
  }

  @override
  String toString() {
    return 'Bubble{id: $id, username: $username, avatarUrl: $avatarUrl, power: $power, friendIDs: $friendIDs, friendshipsLoaded: $friendshipsLoaded,}';
  }
}
