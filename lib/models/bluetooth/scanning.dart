import 'dart:async';

import 'package:befriend/models/bluetooth/uuid_services.dart';
import 'package:befriend/models/data/data_query.dart';
import 'package:befriend/models/data/user_manager.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../views/widgets/profile/scanned_bubble.dart';
import '../data/data_manager.dart';
import '../objects/bubble.dart';

class BluetoothScanning {
  static StreamSubscription? _scanSubscription;

  static Future<void> startScanning(List<ScannedBubble> scannedUsers, Function notifyListeners) async {
    String appUuid = UuidService.getAppUuid();
    Bubble user = await UserManager.getInstance();
    List<dynamic> friendsID = user.friendIDs;

    debugPrint(appUuid);

    _scanSubscription = FlutterBluePlus.onScanResults.listen((results) async {
      if (results.isNotEmpty && results.last.advertisementData.serviceUuids.isNotEmpty) {
        ScanResult result = results.last;

        debugPrint(
            '${result.device.remoteId}: "${result.advertisementData.advName}" found!');

        String uuid = result.advertisementData.serviceUuids.first.toString();
        if (uuid.contains(appUuid)) {
          String string = uuid.substring(19).replaceFirst('-', '');
          int counter = int.parse(string);
          debugPrint('counter is $counter');

          DocumentSnapshot? scannedUserData =
              await DataManager.getData(counter: counter);
          String avatarUrl = scannedUserData.data().toString().contains(Constants.avatarDoc)? scannedUserData.get(Constants.avatarDoc): '';
          ImageProvider avatar = await DataQuery.getAvatarImage(avatarUrl);

          Bubble newBubble = Bubble.fromMapWithoutFriends(scannedUserData, avatar);

          ScannedBubble scannedBubble =
              ScannedBubble(bubble: newBubble, friendsID: friendsID);
          scannedUsers.add(scannedBubble);
          notifyListeners();
        }
      }
    }, onError: (e) => debugPrint(e));

    await FlutterBluePlus.startScan();
  }

  static Future<void> stopScanning() async {
    await FlutterBluePlus.stopScan();
  }

  static Future<void> clearStream(List<ScannedBubble> bubbles) async {
    bubbles.clear();
    await _scanSubscription?.cancel();
    _scanSubscription = null;
  }
}
