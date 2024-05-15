import 'dart:io';

import 'package:befriend/models/data/data_manager.dart';
import 'package:befriend/models/data/data_query.dart';
import 'package:befriend/models/objects/friendship.dart';
import 'package:befriend/models/objects/home.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:befriend/utilities/error_handling.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../objects/bubble.dart';

class UserManager {
  static Bubble? _instance;

  static Future<Home> userHome({Key? key}) async {
    Bubble homeUser = await getInstance();
    return Home.fromUser(homeUser, key: key);
  }

  /// Singleton.
  /// Returns the current player object.
  /// If the player object is not initialized, it is initialized.
  /// The player object is initialized by getting the data from the database.
  static Future<Bubble> getInstance() async {
    if (_instance == null) {
      try {
        DocumentSnapshot docs = await DataManager.getData();

        List<dynamic> friendIDs =
            DataManager.getList(docs, Constants.friendsDoc);
        String avatarUrl = DataManager.getString(docs, Constants.avatarDoc);
        List<Friendship> friendList =
            await DataQuery.friendList(docs.id, friendIDs);

        ImageProvider avatar = await DataQuery.getNetworkImage(avatarUrl);
        _instance = Bubble.fromDocsWithFriends(docs, avatar, friendList);
        debugPrint("(UserManager): User data = $_instance");
      } catch (e) {
        debugPrint(
            '(UserManager): Error initializing user data: ${e.toString()}');
        rethrow;
      }
    }

    return _instance!;
  }

  static Future<void> reloadHome(BuildContext context) async {
    try {
      refreshPlayer();
      Home home = await UserManager.userHome(key: UniqueKey());

      if (context.mounted) {
        debugPrint('(UserManager): Going Home');

        GoRouter.of(context).go(Constants.homepageAddress, extra: home);
      }
    } catch (e) {
      debugPrint('(UserManager): Error reloading home: ${e.toString()}');
      // Optionally show an error message to the user
      if (context.mounted) {
        ErrorHandling.showError(
            context, 'An unexpected error happened. Please try again later...');
      }
    }
  }

  /// refreshPlayer refreshes the player object.
  /// It is necessary to refresh the player object after the player data has been
  /// changed.
  static void refreshPlayer() {
    _instance = null;
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
}
