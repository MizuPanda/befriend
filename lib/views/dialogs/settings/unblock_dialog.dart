import 'package:flutter/material.dart';

import '../../../utilities/app_localizations.dart';

class UnblockDialog {
  static void showUnblockDialog(
      BuildContext context, String username, Function onPressed) {
    final double width = MediaQuery.of(context).size.width;

    showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          bool isLoading = false;

          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text(
                '${AppLocalizations.of(context)?.translate('ud_unblock') ?? 'Unblock'} $username',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Text(
                  "${AppLocalizations.of(context)?.translate('ud_conf') ?? 'Are you sure you want to unblock'} $username?",
                  style: const TextStyle(fontSize: 16)),
              actions: isLoading
                  ? [const CircularProgressIndicator()]
                  : [
                      TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext)
                              .pop(); // Dismiss the dialog
                        },
                        child: Text(
                          AppLocalizations.of(context)
                                  ?.translate('dialog_cancel') ??
                              "Cancel",
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                      SizedBox(
                        width: 10 / 448 * width,
                      ),
                      TextButton(
                        onPressed: () async {
                          setState(() {
                            isLoading = true;
                          });

                          // await Future.delayed(const Duration(seconds: 2));
                          await onPressed();

                          setState(() {
                            isLoading = false;
                          });
                          if (context.mounted) {
                            Navigator.of(dialogContext)
                                .pop(); // Dismiss the dialog
                          }
                        },
                        child: Text(
                            AppLocalizations.of(context)
                                    ?.translate('ud_unblock') ??
                                'Unblock',
                            style: const TextStyle(
                                color: Colors.red, fontSize: 15)),
                      ),
                    ],
            );
          });
        });
  }
}
