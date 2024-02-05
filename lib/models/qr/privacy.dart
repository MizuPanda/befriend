import 'package:befriend/models/objects/bubble.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../views/widgets/home/picture/rounded_dialog.dart';
import '../objects/friendship_progress.dart';
import '../objects/host.dart';

class Privacy {
  Set<FriendshipProgress> _friendships = {};
  Set<String> _friendsAllowed = {};
  bool isPrivate = false;
  bool isPublic = false;

  Set<String> get friendsAllowed => _friendsAllowed;

  void calculateAllowedUsers(Host host, Map<String, double> sliderValuesMap,
      Bubble? Function(String) bubble) {
    // Initial declarations
    _friendsAllowed = {};
    _friendships = {};
    isPrivate = false;
    isPublic = false;

    isPrivate = sliderValuesMap.values.any((privacy) => privacy == 100);

    debugPrint('(Privacy): The picture is ${isPrivate ? '' : 'not '}private');

    if (!isPrivate) {
      // If All x=0 --> public
      // If Any x != 0 --> notPublic;
      isPublic = !sliderValuesMap.values.any((privacy) => privacy != 0);

      if (!isPublic) {
        Map<String, double> userPrivacySettings = _computeUserPrivacySettings(
            host.friendshipsMap, bubble, sliderValuesMap);

        // If all users have no friendships -> then the picture becomes private.
        isPrivate = isPrivate ||
            host.friendshipsMap.values.isEmpty ||
            host.friendshipsMap.values.every((list) => list.isEmpty);
        if (!isPrivate) {
          Set<String> usersAlreadyChecked = {};

          // Check for every user all their friendships
          for (MapEntry<String, List<FriendshipProgress>> entry
              in host.friendshipsMap.entries) {
            // If user has set their privacy to 0, then skip to the next user;
            if (sliderValuesMap[entry.key] == 0) {
              break;
            }

            // Check for every friendship that the user have which friends are allowed
            for (FriendshipProgress friendship in entry.value) {
              String friendId = friendship.friendId();

              if (usersAlreadyChecked.contains(friendId)) {
                usersAlreadyChecked.add(friendId);

                if (_isUserAllowed(friendship, host.friendshipsMap,
                    userPrivacySettings, sliderValuesMap)) {
                  _friendsAllowed.add(friendId);
                  _friendships.add(friendship);
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
      FriendshipProgress friendship,
      Map<String, List<FriendshipProgress>> friendshipsMap,
      Map<String, double> userPrivacySettings,
      Map<String, double> sliderValuesMap) {
    return friendshipsMap.entries.every((sessionUser) {
      // If that user has set his parameters to 0, then true for this session user
      if (sliderValuesMap[sessionUser.key] == 0) {
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
        return false;
      }

      // Finally, if the user is friend with this one, check if their closeness is greater than the privacy setting
      return sessionUserFriendship.level + sessionUserFriendship.progress >=
          userPrivacySettings[sessionUser.key]!;
    });
  }

  Map<String, double> _computeUserPrivacySettings(
      Map<String, List<FriendshipProgress>> friendshipsMap,
      Bubble? Function(String) bubble,
      Map<String, double> sliderValuesMap) {
    return friendshipsMap.map((userId, _) =>
        MapEntry(userId, bubble(userId)!.power * sliderValuesMap[userId]!));
  }

  void showFriendList(BuildContext context, Host host,
      Map<String, double> sliderValuesMap, Bubble? Function(String) bubble) {
    calculateAllowedUsers(host, sliderValuesMap, bubble);

    Widget dialogContent =
        _buildDialogContent(isPublic, isPrivate, _friendships);
    showDialog(
        context: context,
        builder: (BuildContext context) => RoundedDialog(
            child: SizedBox(
                height: Constants.pictureDialogHeight,
                width: Constants.pictureDialogWidth,
                child: dialogContent)));
  }

  Widget _buildDialogContent(
      bool isAllPublic, bool isPrivate, Set<FriendshipProgress> friendships) {
    if (isAllPublic) {
      return Center(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Everyone will be able to see your picture',
            textAlign: TextAlign.center,
            style: GoogleFonts.openSans(
              fontSize: 25,
            )),
      ));
    } else if (isPrivate) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
            child: Text(
                'Only you and your friends in the session will be able to see your picture',
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  fontSize: 25,
                ))),
      );
    } else {
      List<FriendshipProgress> sortedFriendships = friendships.toList()
        ..sort((a, b) => a.friendUsername().compareTo(b.friendUsername()));

      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 5),
          Text('These people will be able to see your picture',
              style: GoogleFonts.openSans()),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: sortedFriendships
                  .map((friendship) => ListTile(
                        title: Text(friendship.friendUsername(),
                            style: GoogleFonts.openSans()),
                      ))
                  .toList(),
            ),
          ),
        ],
      );
    }
  }
}
