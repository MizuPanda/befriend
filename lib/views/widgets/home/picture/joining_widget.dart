import 'package:befriend/models/qr/qr.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:befriend/views/widgets/home/picture/rounded_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../models/authentication/authentication.dart';
import '../../../../models/data/data_manager.dart';
import '../../../../models/objects/bubble.dart';
import '../../../../models/qr/encrypt.dart';
import 'hosting_widget.dart';

class JoiningWidget extends StatefulWidget {
  const JoiningWidget({super.key});

  @override
  State<JoiningWidget> createState() => _JoiningWidgetState();
}

class _JoiningWidgetState extends State<JoiningWidget> {
  late MobileScannerController cameraController;
  bool _isProcessingBarcode = false;

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController();
  }

  @override
  void dispose() {
    super.dispose();
    cameraController.dispose();
  }

  Future<void> _handleBarcodeDetection(BarcodeCapture capture) async {
    if (_isProcessingBarcode) return; // Skip if already processing a barcode
    _isProcessingBarcode = true;

    // Your existing barcode processing logic here
    final List<Barcode> barcodes = capture.barcodes.toSet().toList();
    for (final barcode in barcodes) {
      String? value = barcode.rawValue;

      if (value != null && value.isNotEmpty) {
        String iv = value.split(Constants.dataSeparator).first;
        value = value.substring(iv.length + Constants.dataSeparator.length);

        value = SimpleEncryptionService.decrypt(value, iv);
        debugPrint('(JoiningWidget): Decrypt= $value');
        if (value.contains(Constants.appID)) {
          List<String> values = value.split(Constants.dataSeparator);
          if (values.length == 3) {
            String id = values[1];
            String dateTimeParse = values.last;
            final DateTime dateTime = DateTime.parse(dateTimeParse);

            const Duration oneHour = Duration(hours: 1);

            final DateTime now = DateTime.timestamp();
            final DateTime before = now.subtract(oneHour);
            final DateTime after = now.add(oneHour);

            if (dateTime.compareTo(before) >= 0 &&
                dateTime.compareTo(after) <= 0) {
              DocumentSnapshot data = await DataManager.getData(id: id);
              List<dynamic> joiners =
                  DataManager.getList(data, Constants.hostingDoc);
              if (joiners.length == 10) {
                if (context.mounted) {
                  QR.showLobbyFull(context);
                }
              } else {
                ImageProvider avatar = await DataManager.getAvatar(data);

                Bubble selectedHost =
                    Bubble.fromMapWithoutFriends(data, avatar);

                await Constants.usersCollection.doc(selectedHost.id).update({
                  Constants.hostingDoc:
                      FieldValue.arrayUnion([AuthenticationManager.id()])
                });

                if (mounted) {
                  // Check if the widget is still part of the tree
                  // Safe to use context here
                  context.pop();
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return RoundedDialog(
                          child:
                              HostingWidget(isHost: false, host: selectedHost));
                    },
                  );
                }

                _isProcessingBarcode = false; // Reset the flag after processing
              }
            }
          }
        }
      }
    }
  }

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
                await _handleBarcodeDetection(capture);
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
