import 'package:befriend/utilities/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/data/data_manager.dart';
import '../models/objects/bubble.dart';
import '../models/qr/qr.dart';
import '../models/services/simple_encryption_service.dart';
import '../utilities/constants.dart';
import '../views/dialogs/rounded_dialog.dart';
import '../views/widgets/home/picture/hosting_widget.dart';

class JoiningProvider extends ChangeNotifier {
  final MobileScannerController _cameraController = MobileScannerController();
  bool _isProcessingBarcode = false;

  MobileScannerController get cameraController => _cameraController;

  void disposeState() {
    _cameraController.dispose();
  }

  TorchState torchState() {
    return _cameraController.torchState.value;
  }

  CameraFacing cameraFacingState() {
    return _cameraController.cameraFacingState.value;
  }

  Future<void> switchCamera() async {
    await _cameraController.switchCamera();
    notifyListeners();
  }

  Future<void> toggleTorch() async {
    await _cameraController.toggleTorch();
    notifyListeners();
  }

  Future<void> handleBarcodeDetection(
      BarcodeCapture capture, BuildContext context) async {
    String userId = Models.authenticationManager.id();

    if (_isProcessingBarcode) return; // Skip if already processing a barcode
    _isProcessingBarcode = true;

    try {
      // Your existing barcode processing logic here
      final List<Barcode> barcodes = capture.barcodes.toSet().toList();
      for (final barcode in barcodes) {
        String? value = barcode.rawValue;

        if (value != null && value.isNotEmpty) {
          String iv = value.split(Constants.dataSeparator).first;
          value = value.substring(iv.length + Constants.dataSeparator.length);

          value = SimpleEncryptionService.decrypt(value, iv);
          debugPrint('(JoiningProvider) Decrypt= $value');
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
                DocumentSnapshot data =
                    await Models.dataManager.getData(id: id);
                List<dynamic> joiners =
                    DataManager.getList(data, Constants.hostingDoc);
                Map<String, DateTime> lastSeenMap = DataManager.getDateTimeMap(
                    data, Constants.lastSeenUsersMapDoc);
                String username =
                    DataManager.getString(data, Constants.usernameDoc);

                if (joiners.length == 10) {
                  if (context.mounted) {
                    QR.showLobbyFull(context);
                  }
                } else if (lastSeenMap.containsKey(userId)) {
                  if (context.mounted) {
                    QR.showUserSeenToday(context, username);
                  }
                } else {
                  ImageProvider avatar =
                      await Models.dataManager.getAvatar(data);

                  Bubble selectedHost =
                      Bubble.fromDocsWithoutFriends(data, avatar);

                  await Constants.usersCollection.doc(selectedHost.id).update({
                    Constants.hostingDoc: FieldValue.arrayUnion([userId])
                  });

                  if (context.mounted) {
                    // Check if the widget is still part of the tree
                    // Safe to use context here
                    context.pop();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return RoundedDialog(
                            child: HostingWidget(
                                isHost: false, host: selectedHost));
                      },
                    );
                  }
                }
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('(JoiningProvider) Error processing barcode: $e');
    } finally {
      _isProcessingBarcode = false; // Reset the flag after processing
    }
  }
}
