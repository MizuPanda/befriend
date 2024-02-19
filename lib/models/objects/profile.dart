import 'package:befriend/models/objects/friendship.dart';

import 'bubble.dart';

class Profile {
  Bubble user;
  Friendship? friendship;
  Bubble currentUser;
  Function notifyParent;

  final List<String> commonFriendIds = [];
  final List<String> commonFriendUsernames = [];
  final List<Bubble> commonFriends = [];

  Profile(
      {required this.user,
      required this.friendship,
      required this.currentUser,
      required this.notifyParent}) {
    for (String friendId in user.friendIDs) {
      if (currentUser.friendIDs.contains(friendId)) {
        commonFriendIds.add(friendId);
      }
    }
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

  List<Bubble> getMoreCommonFriends(List<Friendship> moreFriendships) {
    final List<Friendship> friendshipsInCommon = [];

    if (!user.main()) {
      for (String commonFriendId in user.friendIDs) {
        for (Friendship friendship in moreFriendships) {
          if (friendship.friendId() == commonFriendId) {
            friendshipsInCommon.add(friendship);
            break;
          }
        }
      }

      // Sort friends in common based on the power of the friendships
      friendshipsInCommon
          .sort((f1, f2) => f1.strength().compareTo(f2.strength()));
    }

    return friendshipsInCommon.map((e) => e.friend).toList();
  }

  String levelText() {
    return user.main()
        ? 'Social Level: ${user.power}'
        : 'Relationship Level: ${friendship!.level}';
  }
}
