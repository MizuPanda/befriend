import 'package:befriend/models/objects/friendship.dart';

import 'bubble.dart';

class Profile {
  final Bubble user;
  final Friendship? friendship;
  final Bubble currentUser;
  final Function notifyParent;
  int initialIndex;

  final List<Friendship> loadedFriends = [];
  final List<dynamic> commonIDS = [];

  final bool isLocked;

  Profile({
    required this.user,
    required this.friendship,
    required this.currentUser,
    required this.notifyParent,
    this.isLocked = false,
    this.initialIndex = 1,
  }) {
    if (friendship != null && !friendship!.isBestFriend) {
      friendship?.isBestFriend =
          currentUser.bestFriendID == friendship!.friendId();
    }
    initializeCommonFriends();
  }

  void initializeCommonFriends() {
    loadedFriends.clear();
    commonIDS.clear();

    if (!user.main()) {
      commonIDS.addAll(
          user.friendIDs.where((id) => currentUser.friendIDs.contains(id)));

      final List<Friendship> loadedFriendships = currentUser.friendships
          .where((user) => commonIDS.contains(user.friendId()))
          .toList(growable: false);
      loadedFriendships.sort((a, b) => a.strength().compareTo(b.strength()));

      loadedFriends.addAll(loadedFriendships);
    }
  }
}
