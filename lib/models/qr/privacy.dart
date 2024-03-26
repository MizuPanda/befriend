import 'package:befriend/models/objects/bubble.dart';
import 'package:befriend/views/widgets/home/picture/visibility_settings.dart';
import 'package:flutter/material.dart';

import '../objects/friendship_progress.dart';
import '../objects/host.dart';

class Privacy {
  final Set<double> _criticalPoints = {};
  Set<FriendshipProgress> _friendships = {};
  Set<String> _friendsAllowed = {};
  bool isPrivate = false;
  bool isPublic = false;

  Set<String> get friendsAllowed => _friendsAllowed;

  Set<double> get criticalPoints => _criticalPoints;

  void setCriticalPoints(Host host) {
    final Set<double> points = {};
    points.add(0);
    final List<FriendshipProgress>? friendships =
        host.friendshipsMap[host.user.id];

    if (friendships != null) {
      debugPrint('(Privacy): Friendships not null');
      // Formula = friendshipStrength/power >= privacy
      for (FriendshipProgress friendship in friendships) {
        double point = friendship.strength() / host.user.power;
        debugPrint('(Privacy): $point');
        points.add(point);
      }
    }
    points.add(1);

    debugPrint('(Privacy): Critical points = $points');

    _criticalPoints.clear();
    _criticalPoints.addAll(points);
  }

  double privacyFormula({required double privacy, required int power}) {
    // Formula = friendshipStrength >= privacy * power

    return privacy * power;
  }

  void calculateAllowedUsers(Host host, Map<String, double> sliderValuesMap,
      Bubble? Function(String) bubble) {
    // Initial declarations
    _friendsAllowed = {};
    _friendships = {};
    isPrivate = false;
    isPublic = false;

    isPrivate = sliderValuesMap.values.any((privacy) => privacy == 1);

    debugPrint('(Privacy): The picture is ${isPrivate ? '' : 'not '}private');

    if (!isPrivate) {
      // If All x=0 --> public
      // If Any x != 0 --> notPublic;
      isPublic = !sliderValuesMap.values.any((privacy) => privacy != 0);
      debugPrint('(Privacy): The picture is ${isPublic ? '' : 'not '}public');

      if (!isPublic) {
        // If all users have no friendships -> then the picture becomes private.
        isPrivate = host.friendshipsMap.values.isEmpty ||
            host.friendshipsMap.values.every((list) => list.isEmpty);

        if (isPrivate) {
          debugPrint(
              '(Privacy): The picture is private because no users have friendships.');
        }

        if (!isPrivate) {
          Set<String> usersAlreadyChecked = {};

          // Check for every user all their friendships
          for (MapEntry<String, List<FriendshipProgress>> sessionUser
              in host.friendshipsMap.entries) {
            /*
            // If user has set their privacy to 0, then skip to the next user;
            if (sliderValuesMap[sessionUser.key] == 0) {
              debugPrint('(Privacy): ${sessionUser.key} has set their privacy to public, so skip.');
              break;
            }
             */

            debugPrint(
                '(Privacy):   Checking friendships of ${sessionUser.key}');
            // Check for every friendship that the user have which friends are allowed
            for (FriendshipProgress friendship in sessionUser.value) {
              debugPrint(
                  '(Privacy):     Friendship with ${friendship.friendUsername()}');
              String friendId = friendship.friendId();

              debugPrint(
                  '(Privacy):     FriendID is $friendId and userChecked are $usersAlreadyChecked');

              if (!usersAlreadyChecked.contains(friendId)) {
                debugPrint('(Privacy):     Friend not checked yet.');
                usersAlreadyChecked.add(friendId);

                if (!host.joiners.any(
                    (joiner) => joiner.blockedUsers.keys.contains(friendId))) {
                  if (_isUserAllowed(
                      host, friendship, host.friendshipsMap, sliderValuesMap)) {
                    debugPrint(
                        '(Privacy):  ${friendship.friendUsername()} is allowed to see the picture.');
                    _friendsAllowed.add(friendId);
                    _friendships.add(friendship);
                  }
                } else {
                  debugPrint(
                      '(Privacy):  ${friendship.friendUsername()} is blocked by a user.');
                }
              }
            }
          }
        }
      }
    }
  }

  /// Check if friend is allowed by every user to check the picture.
  bool _isUserAllowed(
      Host host,
      FriendshipProgress friendship,
      Map<String, List<FriendshipProgress>> friendshipsMap,
      Map<String, double> sliderValuesMap) {
    return friendshipsMap.entries
        .every((MapEntry<String, List<FriendshipProgress>> sessionUser) {
      double? sliderValue = sliderValuesMap[sessionUser.key];
      debugPrint('(Privacy): ${sessionUser.key} has privacy $sliderValue');
      // If that user has set his parameters to 0, then return true for this session user
      if (sliderValue == null || sliderValue == 0) {
        debugPrint(
            '(Privacy): ${sessionUser.key} allows ${friendship.friendUsername()}. Reason: Public');
        return true;
      }

      FriendshipProgress? sessionUserFriendship;

      // Try to find if the sessionUser has a friendship with the friend we are checking
      for (FriendshipProgress f in sessionUser.value) {
        if (f.friendId() == friendship.friendId()) {
          sessionUserFriendship = f;
        }
      }

      // If they are not friend, then return false which ends the function
      if (sessionUserFriendship == null) {
        debugPrint(
            "(Privacy): ${sessionUser.key} doesn't allow ${friendship.friendUsername()}. Reason: Not friends");
        return false;
      }

      Bubble? bubble;
      for (Bubble b in host.joiners) {
        if (b.id == sessionUser.key) {
          bubble = b;
          break;
        }
      }

      if (bubble == null) {
        throw Exception(
            '(Privacy): Session Users Bubble not found in host.joiners');
      }

      debugPrint('(Privacy): Calculating Formula'
          '\n  Strength=${sessionUserFriendship.strength()}'
          '\n  PrivacyFormula=${privacyFormula(privacy: sliderValue, power: bubble.power)}');
      // Finally, if the user is friend with this one, check if their closeness is greater than the privacy setting
      // Formula = friendshipStrength >= privacy * power
      return sessionUserFriendship.strength() >=
          privacyFormula(privacy: sliderValue, power: bubble.power);
    });
  }

  void showFriendList(BuildContext context, Host host,
      Map<String, double> sliderValuesMap, Bubble? Function(String) bubble) {
    calculateAllowedUsers(host, sliderValuesMap, bubble);

    VisibilityDialog.showVisibilityDialog(context,
        isAllPublic: isPublic, isPrivate: isPrivate, friendships: _friendships);
  }
}
