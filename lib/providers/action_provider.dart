import 'package:befriend/models/data/user_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/data/data_query.dart';
import '../models/objects/bubble.dart';
import '../models/objects/friendship.dart';
import '../models/objects/home.dart';

class ActionProvider extends ChangeNotifier {
  static const int _moreNumber = 5;

  Future<void> refresh(BuildContext context) async {
    await UserManager.reloadHome(context);
  }

  Future<void> loadMore(Home home, Function notifyParent) async {
    try {
      final List<dynamic> randomFriendsIDS =
          home.user.nonLoadedFriends().take(_moreNumber).toList();

      final List<dynamic> nonLoadedMainFriendIDS = [];
      if (!home.user.main()) {
        final Bubble mainUser = await UserManager.getInstance();
        nonLoadedMainFriendIDS.addAll(mainUser.nonLoadedFriends());
        debugPrint(
            '(HomeProvider) non loaded friends: $nonLoadedMainFriendIDS');
      }

      for (String friendID in randomFriendsIDS) {
        Friendship friend =
            await DataQuery.getFriendship(home.user.id, friendID);

        _loadFriend(home, friend);

        // If this is a friend of the connected user that was not loaded yet.
        // --> Add it to main.
        if (nonLoadedMainFriendIDS.contains(friendID) && !home.user.main()) {
          final Friendship friendship =
              await DataQuery.getFriendshipFromBubble(friend.friend);

          UserManager.addFriendToMain(friendship);
          debugPrint(
              '(HomeProvider) Adding friend ${friendship.friend.username} to main user');
        }
        notifyParent();
      }
    } catch (e) {
      debugPrint('(HomeProvider) Error loading friends asynchronously: $e');
    }
  }

  Future<void> _loadFriend(Home home, Friendship friend) async {
    debugPrint('(HomeProvider) Adding ${friend.friend.username} to home');

    home.user.friendships.add(friend);
    home.addFriendToHome(friend);

    // Trigger haptic feedback
    HapticFeedback.mediumImpact();
    home.setPosToMid();
  }
}
