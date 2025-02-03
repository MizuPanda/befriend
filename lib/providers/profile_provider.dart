import 'package:befriend/models/data/user_manager.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:befriend/utilities/error_handling.dart';
import 'package:befriend/views/dialogs/profile/friend_action_dialog.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/objects/bubble.dart';
import '../models/objects/profile.dart';
import '../utilities/app_localizations.dart';
import '../utilities/date_manager.dart';

class ProfileProvider extends ChangeNotifier {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  final Profile profile;

  ProfileProvider({required this.profile});

  Future<void> resetStreak(BuildContext context) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        if (profile.friendship != null) {
          if (profile.friendship!.streak != 0 &&
              DateManager.isBeforeYesterday(
                  profile.friendship!.lastInteraction)) {
            await Constants.friendshipsCollection
                .doc(profile.friendship!.friendshipID)
                .update({
              Constants.streakDoc: 0,
            });

            profile.friendship?.streak = 0;
            notifyListeners();
            debugPrint('(ProfileProvider) Resetting streak to 0');
          }
        }
      } catch (e) {
        debugPrint("(ProfileProvider) Error resetting streak= $e");
      }
    });
  }

  Future<void> onSelectMenu(int? selection, BuildContext context) async {
    switch (selection) {
      case 0: // Delete this user
        await _showActionConfirmation(
            context,
            AppLocalizations.translate(context,
                key: 'pp_df_title', defaultString: "Delete Friend"),
            AppLocalizations.translate(context,
                key: 'pp_df_description',
                defaultString:
                    "Are you sure you want to delete this friend? This action cannot be undone."),
            AppLocalizations.translate(context,
                key: 'pp_df_button', defaultString: "Delete"),
            () => _deleteFriend(context));
        break;
      case 1: // Block this user
        await _showActionConfirmation(
            context,
            AppLocalizations.translate(context,
                key: 'pp_bf_title', defaultString: "Block Friend"),
            AppLocalizations.translate(context,
                key: 'pp_bf_description',
                defaultString:
                    "Are you sure you want to block this friend? This action cannot be undone."),
            AppLocalizations.translate(context,
                key: 'pp_bf_button', defaultString: "Block"),
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
      debugPrint('(ProfileProvider) $action successful: ${result.data}');
      if (context.mounted) {
        await UserManager.reloadHome(context);
      }
    } catch (e) {
      debugPrint('(ProfileProvider) Error $action: $e');
      if (context.mounted) {
        ErrorHandling.showError(
            context,
            AppLocalizations.translate(context,
                key: 'pp_action_error',
                defaultString: 'Error performing action. Please try again.'));
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
    return profile.commonIDS.isEmpty;
  }

  String _other(int sub, BuildContext context) {
    return profile.commonIDS.length - sub == 1
        ? AppLocalizations.translate(context,
            key: 'pp_common_other', defaultString: 'other')
        : AppLocalizations.translate(context,
            key: 'pp_common_others', defaultString: 'others');
  }

  String friendsInCommon(BuildContext context) {
    final int idsLength = profile.commonIDS.length;

    if (profile.loadedFriends.isEmpty) {
      return '$idsLength ${idsLength == 1 ? AppLocalizations.translate(context, key: 'pp_user', defaultString: 'common friend') : AppLocalizations.translate(context, key: 'pp_users', defaultString: 'common friends')}';
    }

    final bool hasNonLoadedCommons = profile.loadedFriends.length != idsLength;

    final Iterable<String> commonFriendUsernames =
        profile.loadedFriends.map((e) => e.friend.username);

    if (hasNonLoadedCommons) {
      switch (commonFriendUsernames.length) {
        case 1:
          return '${commonFriendUsernames.first} ${AppLocalizations.translate(context, key: 'pp_common_and', defaultString: 'and')} ${idsLength - 1} ${_other(1, context)}';
        default:
          return '${commonFriendUsernames.first}, ${commonFriendUsernames.elementAt(1)} ${AppLocalizations.translate(context, key: 'pp_common_and', defaultString: 'and')} ${profile.commonIDS.length - 2} ${_other(2, context)}';
      }
    } else {
      switch (commonFriendUsernames.length) {
        case 1:
          return commonFriendUsernames.first;
        case 2:
          return '${commonFriendUsernames.first} ${AppLocalizations.translate(context, key: 'pp_common_and', defaultString: 'and')} ${commonFriendUsernames.last}';
        default:
          return '${commonFriendUsernames.first}, ${commonFriendUsernames.elementAt(1)} ${AppLocalizations.translate(context, key: 'pp_common_and', defaultString: 'and')} ${profile.commonIDS.length - 2} ${_other(2, context)}';
      }
    }
  }

  void showEditProfileDialog(
      BuildContext context, Bubble bubble, Function notifyParent) {
    GoRouter.of(context).push(Constants.editProfileAddress);
  }

  Color streakColor() {
    int streak =
        profile.user.main() ? profile.user.streak : profile.friendship!.streak;

    return streak == 0
        ? Colors.grey
        : (profile.user.main() ? Colors.blue : Colors.orange);
  }

  String streakText(BuildContext context) {
    if (profile.user.main()) {
      return '${profile.user.streak} ${profile.user.streak == 1 ? AppLocalizations.translate(context, key: 'prfs_day', defaultString: "day") : AppLocalizations.translate(context, key: 'prfs_days', defaultString: "days")}';
    } else {
      return '${profile.friendship!.streak} ${profile.friendship!.streak == 1 ? AppLocalizations.translate(context, key: 'prfs_day', defaultString: "day") : AppLocalizations.translate(context, key: 'prfs_days', defaultString: "days")}';
    }
  }
}
