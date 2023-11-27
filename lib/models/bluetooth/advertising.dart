import 'dart:async';

import 'package:befriend/models/bluetooth/uuid_services.dart';
import 'package:befriend/models/data/user_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';

import '../objects/bubble.dart';

class BluetoothAdvertising {
  static Future<void> startAdvertising() async {
    final peripheral = FlutterBlePeripheral();
    final Bubble player = await UserManager.getInstance();

    // Create a custom AdvertiseData
    String serviceUuid = UuidService.serviceUuid(player.counter,);

    debugPrint("uuid: $serviceUuid");
    final advertiser = AdvertiseData(serviceUuid: serviceUuid);

    await peripheral.start(advertiseData: advertiser);
    debugPrint('Advertising: ${advertiser.serviceUuid}');
  }

  static Future<void> stopAdvertising() async {
    final peripheral = FlutterBlePeripheral();
    await peripheral.stop();
  }
}
