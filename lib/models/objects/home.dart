import 'dart:math';

import 'package:befriend/models/objects/friendship.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:befriend/utilities/models.dart';
import 'package:flutter/cupertino.dart';

import 'bubble.dart';

class Home {
  late Bubble user;
  late Friendship? friendship;
  final bool connectedHome;
  final Key? key;
  bool _showTutorial = false;
  TransformationController? transformationController;

  bool get showTutorial => _showTutorial;

  double _viewerSize = 1500;

  double get viewerSize => _viewerSize;

  static const double _minimumDistanceFactor = 13/20;

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

  void setPosToMid() {
    transformationController?.value = middlePos();
  }

  void initializePositions() {
    for (Friendship friendship in user.friendships) {
      _setBubbleCoordinates(friendship);
    }

    _avoidOverlapping();
    _setViewerSize();
  }

  void addFriendToHome(Friendship friendship) {
    _setBubbleCoordinates(friendship);
    _avoidNewFriendOverlapping();
    _setViewerSizeForNewFriend(friendship.friend);
  }

  void _setBubbleCoordinates(Friendship friendship) {
    final Random rand = Random();
    final Bubble friend = friendship.friend;

    friend.x = rand.nextDouble() * friendship.distance(); // x=6
    friend.y = sqrt(pow(friendship.distance(), 2) -
        pow(friend.x, 2)); //100 - 36 = 64, y = 8

    friend.x += (user.size + friend.size / 2) / 2;
    friend.y += (user.size + friend.size / 2) / 2;

    if (rand.nextBool()) {
      friend.x *= -1;
    }
    if (rand.nextBool()) {
      friend.y *= -1;
    }
  }


  void _setViewerSizeForNewFriend(Bubble newFriend) {
    double distance =
        sqrt(newFriend.x * newFriend.x + newFriend.y * newFriend.y);
    distance += newFriend.size;

    if (distance > _viewerSize / 6) {
      _viewerSize = distance * 6;
      debugPrint('(Home): Updated ViewerSize = $_viewerSize');
    }
  }

  void _setViewerSize() {
    double max = 0;
    _viewerSize = 1500;

    for (Friendship friendship in user.friendships) {
      Bubble friend = friendship.friend;
      double distance = friendship.distance();
      distance += friend.size;

      if (distance > max) {
        max = distance;
      }
    }

    max *= 10;
    debugPrint('(Home) Max = $max');
    if (_viewerSize < max) {
      _viewerSize = max;
    }
    debugPrint('(Home) ViewerSize = $viewerSize');
  }

  void _avoidOverlapping() {
    bool overlapping = true;
    int iterations = 0;
    final int overload = 4*(user.friendIDs.length - Constants.friendsLimit);
    final int maxIterations = 20 + overload > 0? overload : 0;

    user.friendships.sort((a, b) => a.distance().compareTo(b.distance()));
    while (overlapping && iterations < 20) {
      overlapping = false;
      iterations++;

      for (int i = 0; i < user.friendships.length; i++) {
        final bubble = user.friendships[i].friend;

        for (int j = i + 1; j < user.friendships.length; j++) {
          final otherBubble = user.friendships[j].friend;

          final double dx = bubble.x - otherBubble.x;
          final double dy = bubble.y - otherBubble.y;
          final double distance = sqrt(dx * dx + dy * dy);
          final double minDistance = (bubble.size  + otherBubble.size)*_minimumDistanceFactor;


          if (_isOverlapping(distance, minDistance, bubble)) {
            overlapping = true;

            // Adjust position to avoid overlap
            bubble.x += (dx / distance) * bubble.size;
            bubble.y += (dy / distance) * bubble.size;
          }
        }
      }
    }

    if (iterations >= maxIterations) {
      debugPrint('(Home) Maximum number of $iterations surpassed');
    } else {
      debugPrint('(Home) Finished in $iterations iterations');
    }
  }

  void _avoidNewFriendOverlapping() {
    bool overlapping = true;
    final Bubble newFriend = user.friendships.last.friend;
    int iterations = 0;
    final int overload = 2*(user.friendIDs.length - Constants.friendsLimit);
    final int maxIterations = 20 + overload > 0? overload : 0;

    while (overlapping && iterations < maxIterations) {
      overlapping = false;
      iterations++;
      for (int i = 0; i < user.friendships.length - 1; i++) {
        final Bubble otherFriend = user.friendships[i].friend;
        final double dx = newFriend.x - otherFriend.x;
        final double dy = newFriend.y - otherFriend.y;
        final double distance = sqrt(dx * dx + dy * dy);
        final double minDistance = (newFriend.size  + otherFriend.size)*_minimumDistanceFactor;

        if (_isOverlapping(distance, minDistance, newFriend)) {
          overlapping = true;
          // Adjust position to avoid overlap
          newFriend.x += (dx / distance) * newFriend.size;
          newFriend.y += (dy / distance) * newFriend.size;
        }
      }
    }

    if (iterations >= maxIterations) {
      debugPrint('(Home) Error: maximum number of iterations $iterations surpassed');
    } else {
      debugPrint('(Home) Finished in $iterations iterations');
    }
  }

  bool _isOverlapping(double distance, double minimumDistance, Bubble bubble,) {
    return distance < minimumDistance || _isOverlappingCenter(bubble);
  }

  bool _isOverlappingCenter(Bubble bubble,) {
    final double distance = sqrt(bubble.x * bubble.x + bubble.y * bubble.y);
    final double minDistance = (bubble.size + user.size)*_minimumDistanceFactor;

    return distance < minDistance;
  }

  Matrix4 middlePos() {
    // Calculate the initial transformation to center the content
    return Matrix4.identity()..translate(-_viewerSize / 4, -_viewerSize / 4);
  }

  // Tells if a user is a friend with the main connected user.
  bool isFriendToUser() {
    return connectedHome ||
        user.friendIDs.contains(Models.authenticationManager.id());
  }
}
