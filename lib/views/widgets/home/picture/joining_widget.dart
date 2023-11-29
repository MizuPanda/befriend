import 'package:befriend/utilities/constants.dart';
import 'package:befriend/views/widgets/home/picture/rounded_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../models/authentication/authentication.dart';
import '../../../../models/data/data_manager.dart';
import '../../../../models/objects/bubble.dart';
import 'hosting_widget.dart';

class JoiningWidget extends StatefulWidget {
  const JoiningWidget({Key? key}) : super(key: key);

  @override
  State<JoiningWidget> createState() => _JoiningWidgetState();
}

class _JoiningWidgetState extends State<JoiningWidget> {
  MobileScannerController cameraController = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Constants.pictureDialogHeight,
      width: Constants.pictureDialogWidth,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text(
            "Scan your friend's QR Code!",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
          ),
          Container(
            height: Constants.pictureDialogHeight - 150,
            width: Constants.pictureDialogHeight - 150,
            decoration: BoxDecoration(border: Border.all(color: Colors.black)),
            child: MobileScanner(
              // fit: BoxFit.contain,
              controller: cameraController,
              onDetect: (capture) async {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  String? value = barcode.rawValue;
                  if (value != null &&
                      value.isNotEmpty &&
                      value.contains(Constants.appID)) {
                    String id = value.substring(Constants.appID.length + 1);
                    DocumentSnapshot data = await DataManager.getData(id: id);
                    ImageProvider avatar = await DataManager.getAvatar(data);

                    Bubble selectedHost =
                        Bubble.fromMapWithoutFriends(data, avatar);

                    await Constants.usersCollection
                        .doc(selectedHost.id)
                        .update({
                      Constants.hostingDoc:
                          FieldValue.arrayUnion([AuthenticationManager.id()])
                    });

                    if (context.mounted) {
                      context.pop();
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return RoundedDialog(
                                child: HostingWidget(
                                    isHost: false, host: selectedHost));
                          });
                    }
                  }
                }
              },
            ),
          ),
          const SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              IconButton(
                color: Colors.white,
                icon: ValueListenableBuilder(
                  valueListenable: cameraController.torchState,
                  builder: (context, state, child) {
                    switch (state) {
                      case TorchState.off:
                        return const Icon(Icons.flash_off, color: Colors.black);
                      case TorchState.on:
                        return const Icon(Icons.flash_on_outlined,
                            color: Colors.blue);
                    }
                  },
                ),
                iconSize: 32.0,
                onPressed: () => cameraController.toggleTorch(),
              ),
              const SizedBox(
                width: 20,
              ),
              IconButton(
                color: Colors.black,
                icon: ValueListenableBuilder(
                  valueListenable: cameraController.cameraFacingState,
                  builder: (context, state, child) {
                    switch (state) {
                      case CameraFacing.front:
                        return const Icon(Icons.camera_front);
                      case CameraFacing.back:
                        return const Icon(Icons.camera_rear);
                    }
                  },
                ),
                iconSize: 32.0,
                onPressed: () => cameraController.switchCamera(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
