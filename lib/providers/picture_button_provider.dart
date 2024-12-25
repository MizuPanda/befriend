import 'package:befriend/models/qr/host_listening.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

import '../models/authentication/authentication.dart';
import '../utilities/app_localizations.dart';
import '../views/dialogs/home/email_verified_dialog.dart';

class PictureButtonProvider extends ChangeNotifier {
  double _dragPosition = 0.0;
  ButtonMode _buttonMode = ButtonMode.host;

  ButtonMode get mode => _buttonMode;
  double get dragPosition => _dragPosition;

  void onHorizontalDragUpdate(DragUpdateDetails details) {
    _dragPosition += details.delta.dx;
    notifyListeners();
  }

  void onHorizontalDragEnd(DragEndDetails details) {
    _updateMode();
    _dragPosition = 0.0; // Reset position after drag ends
    notifyListeners();
  }

  void _updateMode() {
    if (_dragPosition.abs() > 50) {
      // Switch to join mode if dragged sufficiently to the left
      switchMode();
    }
  }

  void switchMode() {
    switch (_buttonMode) {
      case ButtonMode.host:
        _buttonMode = ButtonMode.join;
        break;
      case ButtonMode.join:
        _buttonMode = ButtonMode.host;
        break;
    }

    notifyListeners();
  }

  Future<void> onPressed(BuildContext context) async {
    try {
      if (AuthenticationManager.isEmailVerified()) {
        await HostListening.pictureButton(context, _buttonMode);
      } else {
        // Show a dialog or notification explaining the restriction
        EmailVerifiedDialog.dialog(context, _buttonMode);
      }
      FirebaseAnalytics.instance.logEvent(name: 'picture_button_press');
    } catch (e) {
      debugPrint('(PictureButtonProvider) Error after pressing: $e');
    }
  }

  List<Color> getGradient(bool isLightMode) {
    switch (_buttonMode) {
      case ButtonMode.host:
        return (isLightMode
            ? const [
                Color.fromRGBO(203, 98, 98, 1.0),
                Color.fromRGBO(213, 18, 18, 1.0),
                Color.fromRGBO(203, 98, 98, 1.0),
              ]
            : const [
                Color.fromRGBO(138, 67, 67, 1.0),
                Color.fromRGBO(155, 15, 15, 1.0),
                Color.fromRGBO(138, 67, 67, 1.0),
              ]);
      case ButtonMode.join:
        return (isLightMode
            ? const [
                Color.fromRGBO(109, 130, 208, 1.0),
                Color.fromRGBO(0, 73, 243, 1.0),
                Color.fromRGBO(109, 130, 208, 1.0),
              ]
            : const [
                Color.fromRGBO(76, 102, 141, 1.0),
                Color.fromRGBO(0, 49, 171, 1.0),
                Color.fromRGBO(76, 102, 141, 1.0),
              ]);
      /*
      case ButtonMode.quick:
        return (isLightMode
            ? const [
          Color.fromRGBO(214, 246, 213, 1.0),
          Color.fromRGBO(144, 238, 145, 1.0),
          Color.fromRGBO(214, 246, 213, 1.0),
        ]
            : const [
          Color.fromRGBO(82, 199, 85, 1.0),
          Color.fromRGBO(5, 102, 8, 1.0),
          Color.fromRGBO(82, 199, 85, 1.0),
        ]);*/
    }
  }

  Color getShadowColor() {
    switch (_buttonMode) {
      case ButtonMode.host:
        return const Color.fromRGBO(213, 18, 18, 0.2);
      case ButtonMode.join:
        return const Color.fromRGBO(0, 73, 243, 0.2);
      /* case ButtonMode.quick:
        return const Color.fromRGBO(82, 199, 85, 0.2); */
    }
  }

  String getText(BuildContext context) {
    switch (_buttonMode) {
      case ButtonMode.host:
        return AppLocalizations.of(context)?.translate('pb_take') ??
            'Start a Group Photo';
      case ButtonMode.join:
        return AppLocalizations.of(context)?.translate('pb_join') ??
            'Join a Group Photo';
      /*
      case ButtonMode.quick:
        return const Color.fromRGBO(82, 199, 85, 0.2);
         */
    }
  }
}

enum ButtonMode { host, join }
