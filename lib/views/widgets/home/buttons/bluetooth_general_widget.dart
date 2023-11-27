import 'package:flutter/material.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';

class BluetoothWidget extends StatelessWidget {
  BluetoothWidget({
    super.key, required this.child,
  });
  final Widget child;

  final FlutterBlePeripheral _peripheral = FlutterBlePeripheral();

  Future<bool> enableBluetooth() async {
    BluetoothPeripheralState state = await _peripheral.hasPermission();
    if(state != BluetoothPeripheralState.granted) {
      await _peripheral.requestPermission();
    }


    if(!(await _peripheral.isConnected)) {
      return await _peripheral.enableBluetooth(askUser: false);
    }

    return true;
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _peripheral.enableBluetooth(askUser: false),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData && snapshot.data == true) {
            debugPrint('(BluetoothGeneral): Loaded. Bluetooth activated');
            return child;
          } else if (!snapshot.hasData) {
            debugPrint('(BluetoothGeneral): Loading....');
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Center(
              child: TextButton(
                  onPressed: () async {
                    await _peripheral.enableBluetooth(askUser: true);
                  },
                  child: const Text('Active the bluetooth')),
            );
          }
        });
  }
}