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
  String name;
  final String avatarUrl;
  final int power;
  ImageProvider avatar;

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
    required this.name,
    required this.power,
    required this.size,
    required this.avatar,
    required this.avatarUrl,
    required this.friendIDs,
    required this.friendshipsLoaded,
  });

  factory Bubble.fromDocsWithFriends(
      DocumentSnapshot docs, ImageProvider avatar, List<Friendship> friends) {
    Bubble bubble = Bubble._fromDocs(docs, avatar, true);
    bubble.friendships = friends;

    return bubble;
  }

  factory Bubble.fromDocsWithoutFriends(
      DocumentSnapshot docs, ImageProvider avatar) {
    Bubble bubble = Bubble._fromDocs(docs, avatar, false);

    return bubble;
  }

  factory Bubble._fromDocs(
      DocumentSnapshot docs, ImageProvider avatar, bool friendshipsLoaded) {
    int pwr = DataManager.getNumber(docs, Constants.powerDoc).toInt();

    double size = 60 + pwr * 55 / 12;

    Bubble bubble = Bubble._(
        id: docs.id,
        name: DataManager.getString(docs, Constants.nameDoc),
        username: DataManager.getString(docs, Constants.usernameDoc),
        power: pwr,
        size: size,
        avatarUrl: DataManager.getString(docs, Constants.avatarDoc),
        friendIDs: DataManager.getList(docs, Constants.friendsDoc),
        friendshipsLoaded: friendshipsLoaded,
        avatar: avatar);

    return bubble;
  }

  bool main() {
    return id == AuthenticationManager.id();
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
    return 'Bubble{id: $id, username: $username, name: $name, avatarUrl: $avatarUrl, power: $power, avatar: $avatar, friendIDs: $friendIDs, friendshipsLoaded: $friendshipsLoaded,}';
  }
}
