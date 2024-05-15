import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../providers/material_provider.dart';
import '../../views/dialogs/rounded_dialog.dart';

class QR {
  static bool areSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static void showLobbyFull(
    BuildContext context,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("The lobby is full"),
        duration: Duration(seconds: 3),
      ),
    );
  }

  static void showUserSeenToday(
    BuildContext context,
    String username,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("You have already seen $username today."),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showQRCodeDialog(
      BuildContext context, String data, int numberOfJoiners) {
    if (numberOfJoiners == 10) {
      showLobbyFull(context);
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return RoundedDialog(
            child: Consumer(builder: (BuildContext context,
                MaterialProvider materialProvider, Widget? child) {
              return QrImageView(
                data: data,
                version: QrVersions.auto,
                size: 300.0,
                backgroundColor: materialProvider.isLightMode(context)
                    ? Colors.transparent
                    : Colors.white,
              );
            }),
          );
        },
      );
    }
  }
}
