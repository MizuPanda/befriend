import 'package:befriend/models/data/user_manager.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

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

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(description, style: const TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss the dialog
              },
              child: const Text(
                "Cancel",
                style: TextStyle(fontSize: textButtonSize),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            TextButton(
              onPressed: () async {
                await onActionConfirmed(); // Call the function that handles the deletion
                if (context.mounted) {
                  Navigator.of(dialogContext).pop(); // Dismiss the dialog
                }
              },
              child: Text(buttonText,
                  style: const TextStyle(
                      color: Colors.red, fontSize: textButtonSize)),
            ),
          ],
        );
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
