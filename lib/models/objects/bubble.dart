import 'dart:math';

import 'package:befriend/models/authentication/authentication.dart';
import 'package:befriend/models/data/data_manager.dart';
import 'package:befriend/models/objects/friendship.dart';
import 'package:befriend/models/objects/profile.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Bubble {
  final String id;
  final String username;
  final String name;
  final String avatarUrl;
  final int counter;
  final int power;
  ImageProvider avatar;

  late List<Friendship> friendships;
  List<dynamic> friendIDs;
  bool friendshipsLoaded;
  //-----------------------
  late double size;
  double x = 0;
  double y = 0;

  final Gradient gradient =  const LinearGradient(
    colors: [Color(0xFFFF5F6D), Color(0xFFFFC371)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  Bubble._({
    required this.id,
    required this.counter,
    required this.username,
    required this.name,
    required this.power,
    required this.avatar,
    required this.avatarUrl,
    required this.friendIDs,
    required this.friendshipsLoaded,
  });


  factory Bubble.fromMapWithFriends(
      DocumentSnapshot docs, ImageProvider avatar, List<Friendship> friends) {
    Bubble bubble = Bubble._(
        id: docs.id,
        name: DataManager.getString(docs, Constants.nameDoc),
        username: DataManager.getString(docs, Constants.usernameDoc),
        counter: DataManager.getNumber(docs, Constants.counterDoc).toInt(),
        power: DataManager.getNumber(docs, Constants.powerDoc).toInt(),
        avatarUrl: DataManager.getString(docs, Constants.avatarDoc),
        friendIDs: DataManager.getList(docs, Constants.friendsDoc),
        friendshipsLoaded: true,
        avatar: avatar);
    bubble.friendships = friends;

    bubble.size = _bubbleSize(bubble);
    //I will have to work on that
    return bubble;
  }

  factory Bubble.fromMapWithoutFriends(
      DocumentSnapshot docs, ImageProvider avatar) {
    Bubble bubble = Bubble._(
        id: docs.id,
        name: DataManager.getString(docs, Constants.nameDoc),
        username: DataManager.getString(docs, Constants.usernameDoc),
        counter: DataManager.getNumber(docs, Constants.counterDoc).toInt(),
        power: DataManager.getNumber(docs, Constants.powerDoc).toInt(),
        avatarUrl: DataManager.getString(docs, Constants.avatarDoc),
        friendIDs: DataManager.getList(docs, Constants.friendsDoc),
        friendshipsLoaded: false,
        avatar: avatar);

    bubble.size = _bubbleSize(bubble);
    //I will have to work on that

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

  static double _bubbleSize(Bubble bubble) {
    return 60 + bubble.power * 55 / 12;
  }

  Point<double> point() {
    return Point(x, y);
  }

  @override
  String toString() {
    return 'Bubble{id: $id, username: $username, name: $name, avatarUrl: $avatarUrl, counter: $counter, power: $power, avatar: $avatar, friendIDs: $friendIDs, friendshipsLoaded: $friendshipsLoaded,}';
  }
}
