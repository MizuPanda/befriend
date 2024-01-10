import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../views/widgets/home/picture/rounded_dialog.dart';

class QR {
  static void showQRCodeDialog(BuildContext context, String data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return RoundedDialog(
          child: QrImageView(
            data: data,
            version: QrVersions.auto,
            size: 300.0,
          ),
        );
      },
    );
  }
}
