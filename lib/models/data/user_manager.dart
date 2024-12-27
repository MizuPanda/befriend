import 'dart:io';

import 'package:befriend/models/authentication/authentication.dart';
import 'package:befriend/models/data/data_manager.dart';
import 'package:befriend/models/objects/home.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:befriend/utilities/error_handling.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../utilities/app_localizations.dart';
import '../objects/bubble.dart';
import '../objects/friendship.dart';
import 'data_query.dart';

class UserManager {
  static Bubble? _instance;
  static Home? _home;

  static Future<Home> userHome({Key? key}) async {
    try {
      if (_home == null) {
        Bubble homeUser = await getInstance();
        _home = Home.fromUser(homeUser, key: key);
      }

      return _home!;
    } catch (e) {
      debugPrint('(UserManager) Error fetching user home: $e');

      rethrow;
    }
  }

  static final Set<String> _usersDetected = {};

  static void addUserDetected(String userId) {
    _usersDetected.add(userId);
  }

  static void resetUsersDetected() {
    _usersDetected.clear();
  }

  static bool userDetectedContains(String userId) {
    return _usersDetected.contains(userId);
  }

  /// Singleton.
  /// Returns the current player object.
  /// If the player object is not initialized, it is initialized.
  /// The player object is initialized by getting the data from the database.
  static Future<Bubble> getInstance() async {
    if (_instance == null) {
      try {
        DocumentSnapshot docs = await DataManager.getData();

        String avatarUrl = DataManager.getString(docs, Constants.avatarDoc);

        ImageProvider avatar = await DataQuery.getNetworkImage(avatarUrl);
        _instance = Bubble.fromDocs(
          docs,
          avatar,
        );

        debugPrint("(UserManager) User data = $_instance");
      } catch (e) {
        debugPrint(
            '(UserManager) Error initializing user data: ${e.toString()}');
        rethrow;
      }
    }

    return _instance!;
  }

  static void addFriendToMain(Friendship friendship) {
    addFriendToList(friendship);
    _setPosToMid();
  }

  static void addFriendToList(Friendship friendship) {
    debugPrint(
        '(UserManager) Added ${friendship.friend.username} to main user');
    _addFriend(friendship);
    _addFriendToHome(friendship);
  }

  static void notify() {
    _instance?.notify();
  }

  static void setNotify(Function function) {
    _instance?.notify = function;
  }

  static void _addFriend(Friendship friendship) {
    _instance?.friendships.add(friendship);
  }

  static void _addFriendToHome(Friendship friendship) {
    _home?.addFriendToHome(friendship);
  }

  static void _setPosToMid() {
    _home?.setPosToMid();
  }

  static Future<void> reloadHome(BuildContext context) async {
    try {
      refreshPlayer();
      Home home = await UserManager.userHome(key: UniqueKey());

      if (context.mounted) {
        debugPrint(
            '(UserManager): Going Home for ${AuthenticationManager.id()}');

        GoRouter.of(context).go(Constants.homepageAddress, extra: home);
      }
    } catch (e) {
      debugPrint('(UserManager): Error reloading home: ${e.toString()}');
      // Optionally show an error message to the user
      if (context.mounted) {
        ErrorHandling.showError(
            context,
            AppLocalizations.of(context)?.translate('general_error_message2') ??
                'An unexpected error happened. Please try again later...');
      }
    }
  }

  /// refreshPlayer refreshes the player object.
  /// It is necessary to refresh the player object after the player data has been
  /// changed.
  static void refreshPlayer() {
    _instance = null;
    _home = null;
  }

  static Future<ImageProvider> refreshAvatar(File file) async {
    try {
      if (_instance != null) {
        _instance!.avatar = Image.file(file).image;
        return _instance!.avatar;
      } else {
        debugPrint('(UserManager): Error refreshing avatar: _instance is null');
        return Image.asset(Constants.defaultPictureAddress)
            .image; // Default image if _instance is null
      }
    } catch (e) {
      debugPrint('(UserManager): Error refreshing avatar: ${e.toString()}');
      return Image.asset(Constants.defaultPictureAddress)
          .image; // Default image on error
    }
  }

  static void setPostNotification(bool value) {
    _instance?.postNotificationOn = value;
  }

  static void setLikeNotification(bool value) {
    _instance?.likeNotificationOn = value;
  }

  static void setLanguageCode(String value) {
    _instance?.languageCode = value;
  }

  static String getBestFriendID() {
    return _instance?.bestFriendID ?? '';
  }

  static void setBestFriendID(String id) {
    _instance?.bestFriendID = id;
  }

  static void removeBlockedUser(String id) {
    _instance?.blockedUsers.remove(id);
  }
}
