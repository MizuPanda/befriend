import 'package:befriend/models/objects/friendship.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../models/objects/bubble.dart';
import '../models/data/picture_manager.dart';
import '../models/objects/profile.dart';
import '../views/dialogs/profile/profile_edit_dialog.dart';

class ProfileProvider extends ChangeNotifier {
  String? _imageUrl;
  final List<String> commonFriendUsernames;
  static final List<Bubble> commonFriends = [];

  ProfileProvider._({required this.commonFriendUsernames});

  factory ProfileProvider.initializeCommonFriends(
      Profile profile, Bubble mainUser) {
    final List<String> friendUsernames = [];
    commonFriends.clear();

    if (!profile.user.main()) {
      final List<_Friend> friendsInCommon = [];

      for (String friendID in profile.user.friendIDs) {
        if (friendID != mainUser.id) {
          for (Friendship friendship in mainUser.friendships) {
            if (friendship.friendId() == friendID) {
              friendsInCommon.add(_Friend(
                  username: friendship.friendUsername(),
                  power: friendship.level + friendship.progress));
              commonFriends.add(friendship.friend);
              break;
            }
          }
        }
      }

      friendsInCommon.sort((f1, f2) => f1.power.compareTo(f2.power));

      friendUsernames.addAll(friendsInCommon.map((e) => e.username));
    }

    return ProfileProvider._(commonFriendUsernames: friendUsernames);
  }

  bool areUsernamesEmpty() {
    return commonFriendUsernames.isEmpty;
  }

  String friendsInCommon() {
    switch (commonFriendUsernames.length) {
      case 1:
        return commonFriendUsernames.first;
      case 2:
        return '${commonFriendUsernames.first} and ${commonFriendUsernames.last}';
      default:
        return '${commonFriendUsernames.first}, ${commonFriendUsernames[1]} and ${commonFriendUsernames.length - 2} others';
    }
  }

  Future<void> changeProfilePicture(
      BuildContext context, Bubble bubble, Function notifyParent) async {
    await PictureManager.takeProfilePicture(context, (String? url) {
      _imageUrl = url;
    });
    if (context.mounted) {
      await _loadPictureChange(context, _imageUrl, bubble, notifyParent);
    }
  }

  void showEditProfileDialog(
      BuildContext context, Bubble bubble, Function notifyParent) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ProfileEditDialog(
          bubble: bubble,
          notifyParent: notifyParent,
        );
      },
    );
  }

  Future<void> _loadPictureChange(BuildContext context, String? imageUrl,
      Bubble bubble, Function notifyParent) async {
    if (_imageUrl == null) {
      if (context.mounted) {
        showTopSnackBar(
            Overlay.of(context),
            const CustomSnackBar.error(
              maxLines: 1,
              message: "Picture change cancelled",
            ),
            snackBarPosition: SnackBarPosition.bottom);
      }
    } else {
      debugPrint('Changing avatar...');
      await PictureManager.changeMainPicture(_imageUrl!, bubble);
      notifyListeners();
      notifyParent();
    }
  }
}

final class _Friend {
  final String username;
  final double power;

  _Friend({required this.username, required this.power});
}
