import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../models/objects/bubble.dart';
import '../models/data/picture_manager.dart';
import '../models/objects/profile.dart';
import '../views/dialogs/profile/profile_edit_dialog.dart';

class ProfileProvider extends ChangeNotifier {
  String? _imageUrl;
  final Profile profile;

  ProfileProvider({required this.profile});

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
