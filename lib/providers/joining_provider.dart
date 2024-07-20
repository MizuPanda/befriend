import 'package:befriend/models/data/user_manager.dart';
import 'package:befriend/models/services/app_links_service.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/qr/qr.dart';
import '../models/services/simple_encryption_service.dart';
import '../utilities/constants.dart';

class JoiningProvider extends ChangeNotifier {
  final MobileScannerController _cameraController = MobileScannerController();
  bool _isProcessingBarcode = false;

  MobileScannerController get cameraController => _cameraController;

  JoiningProvider() {
    UserManager.resetUsersDetected();
  }

  void disposeState() {
    _cameraController.dispose();
  }

  bool torchEnabled() {
    return _cameraController.torchEnabled;
  }

  CameraFacing cameraFacing() {
    return _cameraController.facing;
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
    if (_isProcessingBarcode) return; // Skip if already processing a barcode
    _isProcessingBarcode = true;

    try {
      // Your existing barcode processing logic here
      final List<Barcode> barcodes = capture.barcodes.toSet().toList();
      for (final barcode in barcodes) {
        String? value = barcode.rawValue;

        if (value != null && value.isNotEmpty) {
          final Uri uri = Uri.parse(value);

          if (AppLinksService.isJoinLink(uri)) {
            value = SimpleEncryptionService.getDecryptedURI(
                uri, Constants.dataParameter);

            if (value.contains(Constants.appID)) {
              List<String> values = value.split(Constants.dataSeparator);
              if (values.length == 3) {
                String id = values[1];
                if (!UserManager.userDetectedContains(id)) {
                  UserManager.addUserDetected(id);
                  String dateTimeParse = values.last;

                  if (QR.isExpired(dateTimeParse)) {
                    QR.joinSession(id, context, fromBarcode: true);
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
