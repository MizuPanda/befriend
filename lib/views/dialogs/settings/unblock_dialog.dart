import 'package:flutter/material.dart';

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
                'Unblock $username',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Text("Are you sure you want to unblock $username?",
                  style: const TextStyle(fontSize: 16)),
              actions: isLoading
                  ? [const CircularProgressIndicator()]
                  : [
                      TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext)
                              .pop(); // Dismiss the dialog
                        },
                        child: const Text(
                          "Cancel",
                          style: TextStyle(fontSize: 15),
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
                        child: const Text('Unblock',
                            style: TextStyle(color: Colors.red, fontSize: 15)),
                      ),
                    ],
            );
          });
        });
  }
}
