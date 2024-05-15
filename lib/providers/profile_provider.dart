import 'package:befriend/models/data/user_manager.dart';
import 'package:befriend/utilities/error_handling.dart';
import 'package:befriend/views/dialogs/profile/friend_action_dialog.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import '../models/objects/bubble.dart';
import '../models/data/picture_manager.dart';
import '../models/objects/profile.dart';
import '../views/dialogs/profile/profile_edit_dialog.dart';

class ProfileProvider extends ChangeNotifier {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  String? _imageUrl;
  final Profile profile;

  ProfileProvider({required this.profile});

  Future<void> onSelectMenu(int? selection, BuildContext context) async {
    switch (selection) {
      case 0: // Delete this user
        await _showActionConfirmation(
            context,
            "Delete Friend",
            "Are you sure you want to delete this friend? This action cannot be undone.",
            "Delete",
            () => _deleteFriend(context));
        break;
      case 1: // Block this user
        await _showActionConfirmation(
            context,
            "Block Friend",
            "Are you sure you want to block this friend? This action cannot be undone.",
            "Block",
            () => _blockFriend(context));
        break;
    }
  }

  Future<void> _actionFriend(BuildContext context,
      {required String action}) async {
    try {
      String userId = profile.currentUser.id;
      String friendId = profile.user.id;

      List<String> ids = [userId, friendId];
      ids.sort();

      final result = await _functions.httpsCallable(action).call({
        'userId': userId,
        'targetUserId': friendId,
        'targetUsername': profile.user.username,
        'friendshipId': ids.first + ids.last
      });
      debugPrint('(ProfileProvider): $action successful: ${result.data}');
      if (context.mounted) {
        await UserManager.reloadHome(context);

        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          notifyListeners();
        });
      }
    } catch (e) {
      debugPrint('(ProfileProvider): Error $action: $e');
      if (context.mounted) {
        ErrorHandling.showError(
            context, 'Error performing action. Please try again.');
      }
    }
  }

  Future<void> _deleteFriend(BuildContext context) async {
    await _actionFriend(context, action: 'deleteFriendship');
  }

  Future<void> _blockFriend(BuildContext context) async {
    await _actionFriend(context, action: 'blockUser');
  }

  Future<void> _showActionConfirmation(BuildContext context, String title,
      String description, String buttonText, Function onActionConfirmed) async {
    const double textButtonSize = 15.0;

    FriendActionDialog.showFriendActionDialog(
      context,
      title,
      description,
      buttonText,
      textButtonSize,
      () async {
        await onActionConfirmed(); // Call the function that handles the deletion
      },
    );
  }

  bool areUsernamesEmpty() {
    return profile.commonFriendUsernames.isEmpty;
  }

  String friendsInCommon() {
    switch (profile.commonFriendUsernames.length) {
      case 1:
        return profile.commonFriendUsernames.first;
      case 2:
        return '${profile.commonFriendUsernames.first} and ${profile.commonFriendUsernames.last}';
      default:
        return '${profile.commonFriendUsernames.first}, ${profile.commonFriendUsernames[1]} and ${profile.commonFriendUsernames.length - 2} others';
    }
  }

  Future<void> changeProfilePicture(
      BuildContext context, Bubble bubble, Function notifyParent) async {
    try {
      await PictureManager.takeProfilePicture(context, (String? url) {
        _imageUrl = url;
      });
      if (context.mounted) {
        await _loadPictureChange(context, _imageUrl, bubble, notifyParent);
      }
    } catch (e) {
      debugPrint('(ProfileProvider): Error changing profile picture: $e');
      if (context.mounted) {
        ErrorHandling.showError(
            context, 'Error changing profile picture. Please try again.');
      }
    }
  }

  void showEditProfileDialog(
      BuildContext context, Bubble bubble, Function notifyParent) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ProfileEditDialog(
          bubble: bubble,
          notifyParent: () {
            notifyListeners();
            notifyParent();
          },
        );
      },
    );
  }

  Future<void> _loadPictureChange(BuildContext context, String? imageUrl,
      Bubble bubble, Function notifyParent) async {
    if (_imageUrl == null) {
      const SnackBar snackBar = SnackBar(
        content: Text('Picture change cancelled.'),
        duration: Duration(seconds: 3),
        showCloseIcon: true,
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      try {
        debugPrint('Changing avatar...');
        await PictureManager.changeMainPicture(context, _imageUrl!, bubble);
        notifyListeners();
        notifyParent();
      } catch (e) {
        debugPrint('(ProfileProvider): Error loading picture change: $e');
        if (context.mounted) {
          ErrorHandling.showError(
              context, 'Error loading picture change. Please try again.');
        }
      }
    }
  }
}
