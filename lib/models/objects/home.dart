import 'dart:math';

import 'package:befriend/models/objects/friendship.dart';
import 'package:flutter/cupertino.dart';

import '../authentication/authentication.dart';
import 'bubble.dart';

class Home {
  late Bubble user;
  late Friendship? friendship;
  final bool connectedHome;
  final Key? key;
  bool _showTutorial = false;

  bool get showTutorial => _showTutorial;

  double _viewerSize = 1500;

  double get viewerSize => _viewerSize;

  Home(
      {required this.connectedHome,
      required this.user,
      required this.friendship,
      this.key});

  void activeTutorial() {
    _showTutorial = true;
  }

  void deactivateTutorial() {
    _showTutorial = false;
  }

  factory Home.fromUser(Bubble user, {Key? key}) {
    return Home(connectedHome: true, user: user, friendship: null, key: key);
  }

  factory Home.fromFriendship(Friendship friendship) {
    return Home(
        connectedHome: false, user: friendship.friend, friendship: friendship);
  }

  void initializePositions() {
    Random rand = Random();

    for (Friendship friendship in user.friendships) {
      Bubble friend = friendship.friend;
      friend.x = rand.nextDouble() * friendship.distance(); // x=6
      friend.y = sqrt(pow(friendship.distance(), 2) -
          pow(friend.x, 2)); //100 - 36 = 64, y = 8

      friend.x += (user.size + friend.size / 2) / 2;
      friend.y += (user.size + friend.size / 2) / 2 + user.textHeight();

      if (rand.nextBool()) {
        friend.x *= -1;
      }
      if (rand.nextBool()) {
        friend.y *= -1;
      }
    }

    _avoidOverlapping();
    _setViewerSize();
  }

  void _setViewerSize() {
    double max = 0;

    for (Friendship friendship in user.friendships) {
      Bubble friend = friendship.friend;
      double distance = sqrt(pow(friend.x, 2) + pow(friend.y, 2));

      distance += friend.size;
      if (distance > max) {
        max = distance;
      }
    }

    max *= 6;
    debugPrint('(Home): Max = $max');
    if (_viewerSize < max) {
      _viewerSize = max;
    }
    debugPrint('(Home): ViewerSize = $viewerSize');
  }

  void _avoidOverlapping() {
    bool overlapping = true;

    user.friendships.sort((a, b) => a.distance().compareTo(b.distance()));
    while (overlapping) {
      overlapping = false;
      for (var i = 0; i < user.friendships.length; i++) {
        final bubble = user.friendships[i].friend;

        for (var j = i + 1; j < user.friendships.length; j++) {
          final otherBubble = user.friendships[j].friend;
          final dx = otherBubble.x - bubble.x;
          final dy = otherBubble.y - bubble.y;
          final distance = otherBubble.point().distanceTo(bubble.point());
          final force = bubble.size * otherBubble.size / (distance * distance);

          if (distance < bubble.size + otherBubble.size) {
            overlapping = true;

            otherBubble.x += (dx / distance) * force;
            otherBubble.y += (dy / distance) * force;
          }
        }
      }
    }
  }

  Matrix4 middlePos() {
    // Calculate the initial transformation to center the content

    return Matrix4.identity()..translate(-_viewerSize / 4, -_viewerSize / 4);
  }

  // Tells if a user is a friend with the main connected user.
  bool isFriendToUser() {
    return connectedHome || user.friendIDs.contains(AuthenticationManager.id());
  }
}
