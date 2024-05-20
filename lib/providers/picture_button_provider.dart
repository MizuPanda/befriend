import 'package:flutter/material.dart';

import '../models/authentication/authentication.dart';
import '../models/authentication/consent_manager.dart';
import '../views/dialogs/home/email_verified_dialog.dart';
import '../views/dialogs/rounded_dialog.dart';
import '../views/widgets/home/picture/hosting_widget.dart';
import '../views/widgets/home/picture/joining_widget.dart';

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
    if (AuthenticationManager.isEmailVerified()) {
      // Allow access to the feature
      await ConsentManager.getConsentForm(context, reload: false);

      if (context.mounted) {
        if (_isJoinMode) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return const RoundedDialog(child: JoiningWidget());
              });
        } else {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return const RoundedDialog(
                  child: HostingWidget(isHost: true, host: null),
                );
              });
        }
      }
    } else {
      // Show a dialog or notification explaining the restriction
      EmailVerifiedDialog.dialog(context);
    }
  }
}
