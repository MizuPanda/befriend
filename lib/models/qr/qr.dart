import 'package:befriend/utilities/error_handling.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../providers/material_provider.dart';
import '../../utilities/app_localizations.dart';
import '../../utilities/constants.dart';
import '../../utilities/models.dart';
import '../../views/dialogs/rounded_dialog.dart';
import '../../views/widgets/home/picture/hosting_widget.dart';
import '../data/data_manager.dart';
import '../objects/bubble.dart';
import '../services/simple_encryption_service.dart';

class QR {
  static bool areSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static void showLobbyFull(
    BuildContext context,
  ) {
    ErrorHandling.showError(
        context,
        AppLocalizations.of(context)?.translate('qr_lobby_full') ??
            'The lobby is full');
  }

  static void showUserSeenToday(
    BuildContext context,
    String username,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            "${AppLocalizations.of(context)?.translate('qr_alr_seen') ?? 'You have already seen'} $username ${AppLocalizations.of(context)?.translate('qr_today') ?? 'today'}."),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static String _generateDeepLink(String hostId) {
    String data =
        '${Constants.appID}${Constants.dataSeparator}$hostId${Constants.dataSeparator}${DateTime.now().toIso8601String()}';
    data = SimpleEncryptionService.encrypt64(data);
    data =
        '${SimpleEncryptionService.iv.base64}${Constants.dataSeparator}$data';

    final Uri deepLink = Uri(
      scheme: 'https',
      host: 'befriendesc.com',
      path: Constants.joinPath,
      queryParameters: {'data': Uri.encodeComponent(data)},
    );
    debugPrint('(SimpleEncryptionService) uri=${deepLink.toString()}');

    return deepLink.toString();
  }

  static Future<void> joinSession(String hostId, BuildContext context,
      {required bool fromBarcode}) async {
    try {
      // Your existing logic to join the session using sessionId
      String userId = Models.authenticationManager.id();

      // Fetch the session data
      DocumentSnapshot data = await Models.dataManager.getData(id: hostId);
      List<dynamic> joiners = DataManager.getList(data, Constants.hostingDoc);
      Map<String, DateTime> lastSeenMap =
          DataManager.getDateTimeMap(data, Constants.lastSeenUsersMapDoc);
      String username = DataManager.getString(data, Constants.usernameDoc);

      if (joiners.length == 10) {
        if (context.mounted) {
          QR.showLobbyFull(context);
        }
      } else if (lastSeenMap.containsKey(userId)) {
        if (context.mounted) {
          QR.showUserSeenToday(context, username);
        }
      } else {
        ImageProvider avatar = await Models.dataManager.getAvatar(data);

        Bubble selectedHost = Bubble.fromDocs(data, avatar);

        await Constants.usersCollection.doc(selectedHost.id).update({
          Constants.hostingDoc: FieldValue.arrayUnion([userId])
        });

        if (context.mounted) {
          // Check if the widget is still part of the tree
          // Safe to use context here

          if (fromBarcode && GoRouter.of(context).canPop()) {
            GoRouter.of(context).pop();
          }
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return RoundedDialog(
                  child: HostingWidget(isHost: false, host: selectedHost));
            },
          );
        }
      }
    } catch (e) {
      debugPrint('(QR) Error joining session: $e');
      if (context.mounted) {
        ErrorHandling.showError(
            context,
            AppLocalizations.of(context)?.translate('general_error_message7') ??
                'An unexpected error occurred. Please try again.');
      }
    }
  }

  static bool isExpired(String dateTimeParse) {
    final DateTime dateTime = DateTime.parse(dateTimeParse);

    const Duration oneHour = Duration(hours: 1);

    final DateTime now = DateTime.timestamp();
    final DateTime before = now.subtract(oneHour);
    final DateTime after = now.add(oneHour);

    return dateTime.compareTo(before) >= 0 && dateTime.compareTo(after) <= 0;
  }

  static void showQRCodeDialog(
      BuildContext context, int numberOfJoiners, String userId) {
    if (numberOfJoiners == 10) {
      showLobbyFull(context);
    } else {
      String deepLink = _generateDeepLink(userId);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return RoundedDialog(
            child: Consumer(builder: (BuildContext context,
                MaterialProvider materialProvider, Widget? child) {
              return QrImageView(
                data: deepLink,
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
