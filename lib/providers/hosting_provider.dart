import 'dart:async';

import 'package:befriend/models/authentication/authentication.dart';
import 'package:befriend/models/bluetooth/advertising.dart';
import 'package:befriend/models/data/user_manager.dart';
import 'package:befriend/models/objects/host.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../models/data/data_manager.dart';
import '../models/objects/bubble.dart';

class HostingProvider extends ChangeNotifier {
  late Host _host;
  late List<Bubble> _users;

  static const List<String> linked = ['LINKED'];

  StreamSubscription<DocumentSnapshot>? _stream;

  Future<String> startingHost(BuildContext context) async {
    Bubble user = await UserManager.getInstance();
    _host = Host(host: user, joiners: [], user: user);

    _users = [user];

    if (context.mounted) {
      debugPrint('(HostingProvider): Starting advertising');
      await _startAdvertising(context);
    }

    return 'Completed';
  }

  Future<String> startingJoiner(Bubble host, BuildContext context) async {
    Bubble user = await UserManager.getInstance();
    List<Bubble> users = await _retrieveConnectedJoiners(host, user);
    _host = Host(host: host, joiners: users, user: user);

    _users = users;
    if (context.mounted) {
      _initiateListening(context);
    }

    return 'Completed';
  }

  //region DATA
  bool main() {
    return _host.main();
  }

  bool indexMain(int index) {
    return _users[index] != _host.user;
  }

  Bubble bubble(int index) {
    return _users[index];
  }

  String hostUsername() {
    return _host.host.username;
  }

  int length() {
    return _users.length;
  }

  String name(int index) {
    return _users[index].name;
  }

  String username(int index) {
    return _users[index].username;
  }

  ImageProvider avatar(int index) {
    return _users[index].avatar;
  }

  String power(int index) {
    String formattedNumber =
        NumberFormat.compactCurrency(decimalDigits: 1, symbol: '')
            .format(_users[index].power);

    return 'SP~$formattedNumber';
  }
  //endregion

  static Future<List<Bubble>> _retrieveConnectedJoiners(
      Bubble host, Bubble user) async {
    DocumentSnapshot snapshot = await DataManager.getData(id: host.id);
    List<dynamic> usersHosted =
        DataManager.getList(snapshot, Constants.hostingDoc);

    List<Bubble> joiners = [host];

    for (String id in usersHosted) {
      if (id == user.id) {
        joiners.add(user);
      } else {
        DocumentSnapshot joinerData = await DataManager.getData(id: id);
        ImageProvider avatar = await DataManager.getAvatar(joinerData);
        Bubble joiner = Bubble.fromMapWithoutFriends(joinerData, avatar);

        joiners.add(joiner);
      }
    }

    return joiners;
  }

  void _initiateListening(BuildContext context) {
    _stream = _startListening(context);
    _stream?.resume();
    debugPrint('(HostingProvider): Starting listening...');
  }

  Future<void> onDispose() async {
    if (_host.main()) {
      await stopAdvertising();
      debugPrint('(HostingProvider): Stopping advertisement');
      await Constants.usersCollection
          .doc(_host.host.id)
          .update({Constants.hostingDoc: List.empty()});
    } else {
      await leaveHost();
    }
  }

  /// Starts listening to the changes of the linked list of the current user.
  Future<void> _startAdvertising(BuildContext context) async {
    await BluetoothAdvertising.startAdvertising();
    if (context.mounted) {
      _initiateListening(context);
    }
  }

  /// Deletes the user from the list of the connected users.
  Future<void> deleteUser(int index) async {
    String userId = _users[index].id;

    _users.removeAt(index);
    Constants.usersCollection.doc(_host.host.id).update({
      Constants.hostingDoc: FieldValue.arrayRemove([userId])
    });

    notifyListeners();
  }

  /// Stops advertising.
  /// Stops listening to the changes of the linked list of the current user.
  Future<void> stopAdvertising() async {
    await BluetoothAdvertising.stopAdvertising();
  }

  /// Starts listening to the changes of the hosting document of the host.
  StreamSubscription<DocumentSnapshot> _startListening(BuildContext context) {
    String userId = _host.host.id;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen((snapshot) async {
      List<dynamic> connectedIds =
          DataManager.getList(snapshot, Constants.hostingDoc);
      if (connectedIds.isEmpty) {
        if(!main() && context.mounted) {
          context.pop();
        }
      } else if (connectedIds.toString() == linked.toString()) {
        await Constants.usersCollection
            .doc(userId)
            .update({Constants.hostingDoc: List.empty()});

        if (context.mounted) {
          context.pop();
          context.pop();
        }
        //POSSIBLY REFRESH
      } else {
        //IF NEW USER IN THE LIST
        bool hasBeenRemoved = !main() && (connectedIds.every((id) => id != _host.user.id));

        if(hasBeenRemoved) {
          context.pop();
        } else {
          for (String id in connectedIds) {
            if (_users.every((user) => user.id != id)) { //IF NOT ALREADY IN IN THE LIST
              DocumentSnapshot snapshot = await DataManager.getData(id: id);
              ImageProvider avatar = await DataManager.getAvatar(snapshot);

              Bubble bubble = Bubble.fromMapWithoutFriends(snapshot, avatar);
              _users.add(bubble);
            }

            hasBeenRemoved = id != _host.user.id;
          }
        }
      }
      notifyListeners();
    });
  }

  /// JOINER: Removes the user from the list of the connected users.
  Future<void> leaveHost() async {
    await Constants.usersCollection.doc(_host.host.id).update({
      Constants.hostingDoc: FieldValue.arrayRemove([AuthenticationManager.id()])
    });

    //SHOULD POP OR SOMETHING LIKE THAT
    //FUNCTION IF YOU ARE A USER CONNECTED TO SOMEONE ELSE
  }
}
