import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../../utilities/constants.dart';
import '../data/data_manager.dart';
import '../objects/bubble.dart';
import '../objects/host.dart';

class HostListening {
  static StreamSubscription<DocumentSnapshot> startListening(
      BuildContext context, Host host, Function notifyListeners) {
    String hostUserId = host.host.id;

    return Constants.usersCollection.doc(hostUserId).snapshots().listen(
          (snapshot) =>
              _processSnapshot(snapshot, context, host, notifyListeners),
          onError: _handleError,
        );
  }

  static void _processSnapshot(DocumentSnapshot snapshot, BuildContext context,
      Host host, Function notifyListeners) async {
    try {
      List<dynamic> connectedIds =
          DataManager.getList(snapshot, Constants.hostingDoc);
      debugPrint('(HostListening): $connectedIds');

      if (_hasPictureBeenTaken(connectedIds)) {
        _handlePictureTaken(host, connectedIds);
      }
      if (_isHostTakingPicture(connectedIds)) {
        _handleHostTakingPicture(host);
      } else if (_hasHostStoppedHosting(connectedIds, host)) {
        _handleHostStoppedHosting(context);
      } else {
        await _updateUsersList(connectedIds, context, host);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error processing snapshot: $e');
    }
  }

  static bool _hasPictureBeenTaken(List<dynamic> connectedIds) {
    return connectedIds.first.toString().startsWith(Constants.pictureMarker);
  }

  static bool _isHostTakingPicture(List<dynamic> connectedIds) {
    return connectedIds.first == Constants.pictureState;
  }

  static void _handleHostTakingPicture(Host host) {
    host.state = HostState.picture;
  }

  static bool _hasHostStoppedHosting(List<dynamic> connectedIds, Host host) {
    return !host.main() && connectedIds.isEmpty;
  }

  static void _handlePictureTaken(Host host, List<dynamic> connectedIds) {
    host.imageUrl = connectedIds.first
        .toString()
        .substring('${Constants.pictureMarker}:'.length + 1);
  }

  static void _handleHostStoppedHosting(BuildContext context) {
    if (context.mounted) {
      Navigator.of(context).pop(); // Exiting the picture session
    }
  }

  static Future<void> _updateUsersList(
      List<dynamic> connectedIds, BuildContext context, Host host) async {
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
              Bubble.fromMapWithoutFriends(newUserSnapshot, avatar);
          host.joiners.add(newUser);
        } catch (e) {
          debugPrint('Error adding new user: $e');
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

  static void _handleError(Object error) {
    debugPrint('Error in Firestore subscription: $error');
  }
}
