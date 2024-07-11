import 'package:befriend/models/objects/friendship.dart';

import 'bubble.dart';

class Profile {
  Bubble user;
  Friendship? friendship;
  Bubble currentUser;
  Function notifyParent;
  int initialIndex;

  final List<String> commonFriendUsernames = [];
  final List<Bubble> commonFriends = [];

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
    commonFriends.clear();
    commonFriendUsernames.clear();

    if (!user.main()) {
      final List<Friendship> friendshipsInCommon = [];

      for (String commonFriendId in user.friendIDs) {
        for (Friendship friendship in currentUser.friendships) {
          if (friendship.friendId() == commonFriendId) {
            friendshipsInCommon.add(friendship);
            commonFriends.add(friendship.friend);
            break;
          }
        }
      }

      // Sort friends in common based on the power of the friendships
      friendshipsInCommon
          .sort((f1, f2) => f1.strength().compareTo(f2.strength()));

      commonFriendUsernames
          .addAll(friendshipsInCommon.map((e) => e.friendUsername()));
    }
  }
}
