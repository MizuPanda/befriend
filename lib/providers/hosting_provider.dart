import 'dart:async';

import 'package:befriend/models/authentication/authentication.dart';
import 'package:befriend/models/data/data_query.dart';
import 'package:befriend/models/data/user_manager.dart';
import 'package:befriend/models/objects/host.dart';
import 'package:befriend/models/qr/host_listening.dart';
import 'package:befriend/models/qr/qr.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:befriend/models/qr/simple_encryption_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import '../models/objects/bubble.dart';

class HostingProvider extends ChangeNotifier {
  late Host _host;

  StreamSubscription<DocumentSnapshot>? _stream;

  void showQR(BuildContext context) {
    String data =
        '${Constants.appID}${Constants.dataSeparator}${_host.host.id}${Constants.dataSeparator}${DateTime.timestamp().toIso8601String()}';
    data = SimpleEncryptionService.encrypt64(data);
    data =
        '${SimpleEncryptionService.iv.base64}${Constants.dataSeparator}$data';

    QR.showQRCodeDialog(context, data, _host.joiners.length);
  }

  Future<String> startingHost(BuildContext context) async {
    Bubble user = await UserManager.getInstance();
    debugPrint('(HostingProvider): $user');
    _host = Host(host: user, joiners: [user], user: user);

    final Map<String, DateTime> newLastSeenMap = {};
    DateTime now = DateTime.now();

    for (MapEntry<String, DateTime> entry in user.lastSeenUsersMap.entries) {
      // If the last picture with that user has been taken the same day
      //    --> then, keep the user in the map
      if (QR.areSameDay(now, entry.value)) {
        newLastSeenMap[entry.key] = entry.value;
      }
    }

    await Constants.usersCollection.doc(AuthenticationManager.id()).update({
      Constants.hostingDoc: List.empty(),
      Constants.lastSeenUsersMapDoc: newLastSeenMap
    });
    user.lastSeenUsersMap = newLastSeenMap;

    if (context.mounted) {
      _initiateListening(context);
    }

    return 'Completed';
  }

  Future<String> startingJoiner(Bubble host, BuildContext context) async {
    Bubble user = await UserManager.getInstance();
    _host = Host(host: host, joiners: [host], user: user);

    if (context.mounted) {
      _initiateListening(context);
    }

    return 'Completed';
  }

  //region DATA
  bool isMain() {
    return _host.main();
  }

  Bubble bubble(int index) {
    return _host.joiners[index];
  }

  String hostUsername() {
    return _host.host.username;
  }

  int length() {
    return _host.joiners.length;
  }

  String name(int index) {
    return _host.joiners[index].name;
  }

  String username(int index) {
    return _host.joiners[index].username;
  }

  ImageProvider avatar(int index) {
    return _host.joiners[index].avatar;
  }

  //endregion

  void _initiateListening(BuildContext context) {
    _stream = HostListening.startListening(context, _host, notifyListeners);
    _stream?.resume();
    debugPrint('(HostingProvider): Starting listening...');
  }

  Future<void> onDispose() async {
    await _stream?.cancel();
    dispose();
  }

  /// Deletes the user from the list of the connected users.
  Future<void> deleteUser(int index) async {
    String userId = _host.joiners[index].id;

    _host.joiners.removeAt(index);
    Constants.usersCollection.doc(_host.host.id).update({
      Constants.hostingDoc: FieldValue.arrayRemove([userId])
    });

    notifyListeners();
  }

  Future<void> startSession() async {
    List<dynamic> sessionUsers = [Constants.pictureState];
    List<String> userIds = _host.joiners.map((e) => e.id).toList();
    sessionUsers.addAll(userIds);

    await _generateFriendshipMap(userIds, _host.host.id);
    await DataQuery.updateDocument(Constants.hostingDoc, sessionUsers);
  }

  Future<void> _generateFriendshipMap(
      List<String> sessionUsers, String hostId) async {
    FirebaseFunctions functions = FirebaseFunctions.instance;

    try {
      final result =
          await functions.httpsCallable('generateFriendshipMap').call({
        'sessionUsers': sessionUsers,
        'hostId': hostId,
      });

      // The cloud function returns { success: true } upon successful completion
      debugPrint('(HostingProvider): Function call success: ${result.data}');
    } catch (e) {
      debugPrint('(HostingProvider): Error calling cloud function: $e');
    }
  }
}
