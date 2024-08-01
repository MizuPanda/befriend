import 'package:befriend/models/objects/friendship.dart';

import 'bubble.dart';

class Profile {
  Bubble user;
  Friendship? friendship;
  Bubble currentUser;
  Function notifyParent;
  int initialIndex;

  final List<Friendship> loadedFriends = [];
  final List<dynamic> commonIDS = [];

  Profile({
    required this.user,
    required this.friendship,
    required this.currentUser,
    required this.notifyParent,
    this.initialIndex = 1,
  }) {
    initializeCommonFriends();
  }

  void initializeCommonFriends() {
    loadedFriends.clear();
    commonIDS.clear();

    if (!user.main()) {
      commonIDS.addAll(user.friendIDs.where((id) => currentUser.friendIDs.contains(id)));

      final List<Friendship> loadedFriendships = currentUser.friendships.where((user) => commonIDS.contains(user.friendId())).toList(growable: false);
      loadedFriendships.sort((a, b) => a.strength().compareTo(b.strength()));

      loadedFriends.addAll(loadedFriendships);
    }
  }
}
