import 'package:befriend/models/qr/host_listening.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

import '../models/authentication/authentication.dart';
import '../views/dialogs/home/email_verified_dialog.dart';

class PictureButtonProvider extends ChangeNotifier {
  double _dragPosition = 0.0;
  bool _isJoinMode = false;

  bool get isJoinMode => _isJoinMode;
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
    _isJoinMode = !_isJoinMode;
    notifyListeners();
  }

  Future<void> onPressed(BuildContext context) async {
    try {
      if (AuthenticationManager.isEmailVerified()) {
        await HostListening.pictureButton(context, _isJoinMode);
      } else {
        // Show a dialog or notification explaining the restriction
        EmailVerifiedDialog.dialog(context, _isJoinMode);
      }
      FirebaseAnalytics.instance.logEvent(name: 'picture_button_press');
    } catch (e) {
      debugPrint('(PictureButtonProvider) Error after pressing: $e');
    }
  }
}
