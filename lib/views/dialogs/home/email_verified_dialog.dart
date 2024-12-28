import 'package:befriend/models/authentication/authentication.dart';
import 'package:befriend/models/qr/host_listening.dart';
import 'package:flutter/material.dart';

import '../../../providers/picture_button_provider.dart';
import '../../../utilities/app_localizations.dart';

class EmailVerifiedDialog {
  static void dialog(BuildContext context, ButtonMode isJoinMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.translate(context,
            key: 'evd_title', defaultString: 'Email Verification Required')),
        content: Text(AppLocalizations.translate(context,
            key: 'evd_content',
            defaultString: 'Please verify your email to access this feature.')),
        actions: [
          TextButton(
            onPressed: () async {
              AuthenticationManager.sendEmailVerification(context);
              Navigator.of(context).pop();
              await HostListening.pictureButton(context, isJoinMode);
            },
            child: Text(AppLocalizations.translate(context,
                key: 'evd_child', defaultString: 'Resend Email')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await HostListening.pictureButton(context, isJoinMode);
            },
            child: Text(AppLocalizations.translate(context,
                key: 'dialog_ok', defaultString: 'OK')),
          ),
        ],
      ),
    );
  }
}
