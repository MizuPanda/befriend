import 'dart:async';

import 'package:befriend/utilities/error_handling.dart';
import 'package:befriend/utilities/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../utilities/app_localizations.dart';
import '../../utilities/constants.dart';
import '../../views/dialogs/rounded_dialog.dart';
import '../../views/widgets/home/picture/hosting_widget.dart';
import '../../views/widgets/home/picture/joining_widget.dart';
import '../authentication/consent_manager.dart';
import '../data/data_manager.dart';
import '../objects/bubble.dart';
import '../objects/host.dart';

class HostListening {
  static bool _isTakingPicture = false;

  static StreamSubscription<DocumentSnapshot> startListening(
      BuildContext context, Host host, Function notifyListeners) {
    _isTakingPicture = false;
    String hostUserId = host.host.id;

    return Constants.usersCollection.doc(hostUserId).snapshots().listen(
      (snapshot) => _processSnapshot(snapshot, context, host, notifyListeners),
      onError: (error) {
        debugPrint('(HostListening): Error in Firestore subscription: $error');
        ErrorHandling.showError(
            context,
            AppLocalizations.of(context)?.translate('general_error_message3') ??
                'An error occurred. Please try again later...');
      },
    );
  }

  static void _processSnapshot(DocumentSnapshot snapshot, BuildContext context,
      Host host, Function notifyListeners) async {
    try {
      List<dynamic> connectedIds =
          DataManager.getList(snapshot, Constants.hostingDoc);
      debugPrint('(HostListening): $connectedIds');

      if (_isHostTakingPicture(connectedIds)) {
        debugPrint('(HostListening): Host is taking picture');
        _handleHostTakingPicture(host, context);
      } else if (_hasHostStoppedHosting(connectedIds, host)) {
        debugPrint('(HostListening): Host has stopped hosting');
        _handleHostStoppedHosting(context);
      } else {
        debugPrint('(HostListening): Updating user list');
        await _updateUsersList(connectedIds, context, host);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('(HostListening): Error processing snapshot: $e');
      if (context.mounted) {
        ErrorHandling.showError(
            context,
            AppLocalizations.of(context)?.translate('general_error_message4') ??
                'An unknown error occurred...');
      }
    }
  }

  static bool _isHostTakingPicture(List<dynamic> connectedIds) {
    return connectedIds.isNotEmpty &&
        connectedIds.first.toString() == Constants.pictureState;
  }

  static bool _hasHostStoppedHosting(List<dynamic> connectedIds, Host host) {
    return !host.main() && connectedIds.isEmpty;
  }

  static void _handleHostTakingPicture(Host host, BuildContext context) {
    try {
      _isTakingPicture = true;
      if (GoRouter.of(context).canPop()) {
        GoRouter.of(context).pop();
      }

      GoRouter.of(context).go(Constants.sessionAddress, extra: host);
    } catch (e) {
      debugPrint('(HostListening): Error handling host taking picture: $e');
      // Optionally, show an error message to the user
    }
  }

  static void _handleHostStoppedHosting(BuildContext context) {
    try {
      if (context.mounted &&
          !_isTakingPicture &&
          GoRouter.of(context).canPop()) {
        GoRouter.of(context).pop(); // Exiting the picture session
      }
    } catch (e) {
      debugPrint('(HostListening): Error handling host stopped hosting: $e');
      // Optionally, show an error message to the user
      ErrorHandling.showError(
          context,
          AppLocalizations.of(context)?.translate('general_error_message4') ??
              'An unexpected error occurred...');
    }
  }

  static Future<void> _updateUsersList(
      List<dynamic> connectedIds, BuildContext context, Host host) async {
    try {
      debugPrint('(HostListening): $connectedIds');
      // Remove users who left
      host.joiners.removeWhere((user) =>
          (user.id != host.host.id && !connectedIds.contains(user.id)));

      // Check if current user has been removed
      _handleCurrentUserRemoved(connectedIds, context, host);

      // Add new users
      for (String id in connectedIds) {
        if (host.joiners.every((user) => user.id != id)) {
          try {
            DocumentSnapshot newUserSnapshot =
                await Models.dataManager.getData(id: id);
            ImageProvider avatar =
                await Models.dataManager.getAvatar(newUserSnapshot);
            Bubble newUser = Bubble.fromDocs(newUserSnapshot, avatar);
            host.joiners.add(newUser);
          } catch (e) {
            debugPrint('(HostListening): Error adding new user: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('(HostListening): Error updating users list: $e');
      // Optionally, show an error message to the user
    }
  }

  static void _handleCurrentUserRemoved(
    List<dynamic> connectedIds,
    BuildContext context,
    Host host,
  ) {
    if (!host.main() &&
        !connectedIds.contains(host.user.id) &&
        context.mounted &&
        GoRouter.of(context).canPop()) {
      GoRouter.of(context).pop(); // Exiting the picture session
    }
  }

  static Future<void> onDispose(Host host) async {
    if (!_isTakingPicture) {
      if (host.main()) {
        debugPrint('(HostListening): Stopping hosting');
        await Constants.usersCollection
            .doc(host.host.id)
            .update({Constants.hostingDoc: List.empty()});
        await Constants.usersCollection
            .doc(host.host.id)
            .update({Constants.hostingFriendshipsDoc: {}});
      } else {
        debugPrint('(HostListening): Stopping joining');
        await _leaveHost(host);
      }
    }
  }

  static Future<void> _leaveHost(Host host) async {
    if (host.joiners.contains(host.user)) {
      await Constants.usersCollection.doc(host.host.id).update({
        Constants.hostingDoc: FieldValue.arrayRemove([host.user.id])
      });
    }
  }

  static Future<void> pictureButton(
      BuildContext context, bool isJoinMode) async {
    // Allow access to the feature
    await ConsentManager.getConsentForm(context, reload: false);

    if (context.mounted) {
      if (isJoinMode) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return const RoundedDialog(child: JoiningWidget());
            });
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return const RoundedDialog(
                child: HostingWidget(isHost: true, host: null),
              );
            });
      }
    }
  }
}
