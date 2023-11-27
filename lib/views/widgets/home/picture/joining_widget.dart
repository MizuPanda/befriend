import 'package:befriend/utilities/constants.dart';
import 'package:flutter/material.dart';

import '../buttons/bluetooth_general_widget.dart';
import 'nearby_devices.dart';

class JoiningWidget extends StatefulWidget {
  const JoiningWidget({Key? key}) : super(key: key);

  @override
  State<JoiningWidget> createState() => _JoiningWidgetState();
}

class _JoiningWidgetState extends State<JoiningWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height:Constants.pictureDialogHeight,
      width: Constants.pictureDialogWidth,
      padding: const EdgeInsets.all(20.0),
      child: BluetoothWidget(
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              'Nearby users',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
            Expanded(child: NearbyDevicesList()),
            SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}
