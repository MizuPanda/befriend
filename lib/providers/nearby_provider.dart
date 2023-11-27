import 'dart:async';

import 'package:befriend/models/authentication/authentication.dart';
import 'package:befriend/models/bluetooth/scanning.dart';
import 'package:befriend/models/objects/bubble.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:befriend/views/widgets/home/picture/bluetooth_dialog.dart';
import 'package:befriend/views/widgets/home/picture/hosting_widget.dart';
import 'package:befriend/views/widgets/profile/scanned_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NearbyProvider extends ChangeNotifier {
  final List<ScannedBubble> _scannedBubbles = <ScannedBubble>[];

  Bubble bubble(int index) {
    return _scannedBubbles[index].bubble;
  }

  /// Returns the username of scanned device at index
  String username(int index) {
    return _scannedBubbles[index].bubble.username;
  }

  /// Returns the social level of scanned device at index
  int socialLevel(int index) {
    return _scannedBubbles[index].bubble.power;
  }

  /// Tells if the scanned device at index is already a friend
  bool isFriend(int index) {
    return _scannedBubbles[index].alreadyFriend;
  }

  /// Returns the avatar of scanned device at index
  ImageProvider avatar(int index) {
    return _scannedBubbles[index].bubble.avatar;
  }

  /// Returns the length of the scanned devices list
  int length() {
    return _scannedBubbles.length;
  }

  /// Starts the scanning process
  Future<void> startScanning() async {
    await BluetoothScanning.startScanning(_scannedBubbles, notifyListeners);
  }

  /// Stops the scanning process
  Future<void> stopScanning() async {
    await BluetoothScanning.clearStream(_scannedBubbles);
    await BluetoothScanning.stopScanning();
  }


  /// Connects to the host.
  /// Add the user to the list of the connected users.
  /// Starts listening to the changes of the linked list of the selected host.
  Future<void> onTap(int index, BuildContext context) async {
    Bubble selectedHost = _scannedBubbles[index].bubble;
    await Constants.usersCollection
        .doc(selectedHost.id)
        .update({
      Constants.hostingDoc: FieldValue.arrayUnion([AuthenticationManager.id()])
    });


    if(context.mounted) {
      context.pop();
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return BluetoothDialog(child: HostingWidget(isHost: false, host: selectedHost));
          }
      );
    }
  }
}
