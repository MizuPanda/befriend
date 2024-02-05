import 'dart:async';

import 'package:befriend/models/data/data_query.dart';
import 'package:befriend/models/data/friend_manager.dart';
import 'package:befriend/models/data/user_manager.dart';
import 'package:befriend/models/objects/friendship_progress.dart';
import 'package:befriend/models/objects/host.dart';
import 'package:befriend/models/qr/host_listening.dart';
import 'package:befriend/models/qr/qr.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/objects/bubble.dart';

class HostingProvider extends ChangeNotifier {
  late Host _host;

  StreamSubscription<DocumentSnapshot>? _stream;

  void showQR(BuildContext context) {
    QR.showQRCodeDialog(
        context, '${Constants.appID}.${_host.host.id}', _host.joiners.length);
  }

  Future<String> startingHost(BuildContext context) async {
    Bubble user = await UserManager.getInstance();
    debugPrint('(UserManager): ${user.toString()}');
    _host = Host(host: user, joiners: [user], user: user);
    await DataQuery.updateDocument(Constants.hostingDoc, List.empty());

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
    await HostListening.onDispose(_host);

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
    Map<String, List<FriendshipProgress>> idToFriendships =
        await FriendManager.fetchFriendshipsForUsers(userIds);

    await DataQuery.updateDocument(Constants.hostingDoc, sessionUsers);
    await DataQuery.updateDocument(
        Constants.hostingFriendships, idToFriendships);
  }
}
