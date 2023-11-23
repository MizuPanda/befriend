import 'dart:math';

import 'package:befriend/models/authentication/authentication.dart';
import 'package:befriend/models/objects/friendship.dart';
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
  late List<Friendship> friendships;
  List<dynamic> friendIDs;
  bool friendshipsLoaded;
  //-----------------------
  late int level;
  late double size;
  double x = 0;
  double y = 0;
  ImageProvider? avatar;

  final Gradient gradient = const RadialGradient(
    colors: [Colors.green, Colors.lightGreenAccent],
  );

  Bubble({
    required this.id,
    required this.counter,
    required this.username,
    required this.name,
    required this.power,
    required this.avatarUrl,
    required this.friendIDs,
    required this.friendshipsLoaded,
  });

  factory Bubble.fromMapWithFriends(
      DocumentSnapshot docs, List<Friendship> friends) {
    String data = docs.data().toString();

    Bubble bubble = Bubble(
      id: docs.id,
      name: data.contains(Constants.nameDoc) ? docs.get(Constants.nameDoc) : '',
      username: data.contains(Constants.usernameDoc)
          ? docs.get(Constants.usernameDoc)
          : '',
      counter: data.contains(Constants.counterDoc)
          ? docs.get(Constants.counterDoc)
          : -1,
      power:
          data.contains(Constants.powerDoc) ? docs.get(Constants.powerDoc) : -1,
      avatarUrl: data.contains(Constants.avatarDoc)
          ? docs.get(Constants.avatarDoc)
          : '',
      friendIDs: data.contains(Constants.friendsDoc)
          ? docs.get(Constants.friendsDoc)
          : List.empty(),
      friendshipsLoaded: true,
    );
    bubble.friendships = friends;

    bubble.size = 60 + bubble.level * 55 / 12;
    //I will have to work on that
    return bubble;
  }

  factory Bubble.fromMapWithoutFriends(DocumentSnapshot docs) {
    String data = docs.data().toString();

    Bubble bubble = Bubble(
      id: docs.id,
      name: data.contains('name') ? docs.get('name') : '',
      username: data.contains('username') ? docs.get('username') : '',
      counter: data.contains('counter') ? docs.get('counter') : -1,
      power: data.contains('power') ? docs.get('power') : -1,
      avatarUrl: data.contains('avatar') ? docs.get('avatar') : '',
      friendIDs: data.contains(Constants.friendsDoc)
          ? docs.get(Constants.friendsDoc)
          : List.empty(),
      friendshipsLoaded: false,
    );

    bubble.size = 60 + bubble.level * 55 / 12;
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

  String levelText() {
    return main() ? 'Social Level' : 'Relationship Level';
  }

  String levelNumberText() {
    if (main()) {
      return level.toString();
    } else {
      return friendships
          .firstWhere((friendship) => friendship.friend.main())
          .level
          .toString();
    }
  }


  Point<double> point() {
    return Point(x, y);
  }
}
