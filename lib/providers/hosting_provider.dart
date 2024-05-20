import 'dart:async';

import 'package:befriend/models/authentication/authentication.dart';
import 'package:befriend/models/data/data_query.dart';
import 'package:befriend/models/data/user_manager.dart';
import 'package:befriend/models/objects/host.dart';
import 'package:befriend/models/qr/host_listening.dart';
import 'package:befriend/models/qr/qr.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:befriend/models/services/simple_encryption_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

import '../models/objects/bubble.dart';

class HostingProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  late Host _host;
  bool showTutorial = false;
  StreamSubscription<DocumentSnapshot>? _stream;

  final GlobalKey _one = GlobalKey();
  final GlobalKey _two = GlobalKey();

  GlobalKey get one => _one;
  GlobalKey get two => _two;

  void _initShowcase(BuildContext context) {
    debugPrint('(HostingProvider): showTutorial= $showTutorial');
    if (showTutorial) {
      WidgetsBinding.instance.addPostFrameCallback((_) => showCase(context));
    }
  }

  void showCase(BuildContext context) {
    ShowCaseWidget.of(context).startShowCase([_one, _two]);
  }

  void showQR(BuildContext context) {
    String data =
        '${Constants.appID}${Constants.dataSeparator}${_host.host.id}${Constants.dataSeparator}${DateTime.now().toIso8601String()}';
    data = SimpleEncryptionService.encrypt64(data);
    data =
        '${SimpleEncryptionService.iv.base64}${Constants.dataSeparator}$data';

    QR.showQRCodeDialog(context, data, _host.joiners.length);
  }

  Future<String> startingHost(BuildContext context) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      showTutorial = prefs.getBool(Constants.showHostTutorialKey) ?? true;
      if (showTutorial) {
        await prefs.setBool(Constants.showHostTutorialKey, false);
      }

      Bubble user = await UserManager.getInstance();
      debugPrint('(HostingProvider): $user');
      _host = Host(host: user, joiners: [user], user: user);

      final Map<String, DateTime> newLastSeenMap = {};
      DateTime now = DateTime.now();

      for (MapEntry<String, DateTime> entry in user.lastSeenUsersMap.entries) {
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
        _initShowcase(context);
      }

      return 'Completed';
    } catch (e) {
      debugPrint('(HostingProvider): Error starting host: $e');
      return 'Error';
    }
  }

  Future<String> startingJoiner(Bubble host, BuildContext context) async {
    try {
      showTutorial = false;
      Bubble user = await UserManager.getInstance();
      _host = Host(host: host, joiners: [host], user: user);

      if (context.mounted) {
        _initiateListening(context);
      }

      return 'Completed';
    } catch (e) {
      debugPrint('(HostingProvider): Error starting joiner: $e');
      return 'Error';
    }
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
    try {
      String userId = _host.joiners[index].id;
      _host.joiners.removeAt(index);
      await Constants.usersCollection.doc(_host.host.id).update({
        Constants.hostingDoc: FieldValue.arrayRemove([userId])
      });
      notifyListeners();
    } catch (e) {
      debugPrint('(HostingProvider): Error deleting user: $e');
    }
  }

  Future<void> startSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      List<dynamic> sessionUsers = [Constants.pictureState];
      List<String> userIds = _host.joiners.map((e) => e.id).toList();
      sessionUsers.addAll(userIds);

      await _generateFriendshipMap(userIds, _host.host.id);
      await DataQuery.updateDocument(Constants.hostingDoc, sessionUsers);

      debugPrint('(HostingProvider): Session started successfully.');
    } catch (e) {
      debugPrint('(HostingProvider): Error starting session: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

      debugPrint('(HostingProvider): Function call success: ${result.data}');
    } catch (e) {
      debugPrint('(HostingProvider): Error calling cloud function: $e');
    }
  }
}
