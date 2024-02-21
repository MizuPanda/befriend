import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../utilities/constants.dart';
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
        _handleHostTakingPicture(host, context);
      } else if (_hasHostStoppedHosting(connectedIds, host)) {
        _handleHostStoppedHosting(context);
      } else {
        await _updateUsersList(connectedIds, context, host);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('(HostListening): Error processing snapshot: $e');
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
    _isTakingPicture = true;
    Navigator.of(context).pop();

    GoRouter.of(context).go(Constants.sessionAddress, extra: host);
  }

  static void _handleHostStoppedHosting(BuildContext context) {
    if (context.mounted && !_isTakingPicture) {
      Navigator.of(context).pop(); // Exiting the picture session
    }
  }

  static Future<void> _updateUsersList(
      List<dynamic> connectedIds, BuildContext context, Host host) async {
    debugPrint('(HostListening): $connectedIds');
    // Remove users who left
    host.joiners.removeWhere(
        (user) => (user.id != host.host.id && !connectedIds.contains(user.id)));

    // Check if current user has been removed
    _handleCurrentUserRemoved(connectedIds, context, host);

    // Add new users
    for (String id in connectedIds) {
      if (host.joiners.every((user) => user.id != id)) {
        try {
          DocumentSnapshot newUserSnapshot = await DataManager.getData(id: id);
          ImageProvider avatar = await DataManager.getAvatar(newUserSnapshot);
          Bubble newUser =
              Bubble.fromDocsWithoutFriends(newUserSnapshot, avatar);
          host.joiners.add(newUser);
        } catch (e) {
          debugPrint('(HostListening): Error adding new user: $e');
        }
      }
    }
  }

  static void _handleCurrentUserRemoved(
    List<dynamic> connectedIds,
    BuildContext context,
    Host host,
  ) {
    if (!host.main() &&
        !connectedIds.contains(host.user.id) &&
        context.mounted) {
      Navigator.of(context).pop(); // Exiting the picture session
    }
  }
}
