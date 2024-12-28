import 'package:flutter/material.dart';

import '../../../utilities/app_localizations.dart';

class FriendActionDialog {
  static void showFriendActionDialog(
      BuildContext context,
      String title,
      String description,
      String buttonText,
      double textButtonSize,
      Function onPressed) {
    final double width = MediaQuery.of(context).size.width;

    showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          bool isLoading = false;

          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Text(description, style: const TextStyle(fontSize: 16)),
              actions: isLoading
                  ? [const CircularProgressIndicator()]
                  : [
                      TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext)
                              .pop(); // Dismiss the dialog
                        },
                        child: Text(
                          AppLocalizations.translate(context,
                              key: 'dialog_cancel', defaultString: "Cancel"),
                          style: TextStyle(fontSize: textButtonSize),
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
                          await onPressed();
                          // await Future.delayed(const Duration(seconds: 2));
                          setState(() {
                            isLoading = false;
                          });
                          if (context.mounted) {
                            Navigator.of(dialogContext)
                                .pop(); // Dismiss the dialog
                          }
                        },
                        child: Text(buttonText,
                            style: TextStyle(
                                color: Colors.red, fontSize: textButtonSize)),
                      ),
                    ],
            );
          });
        });
  }
}
