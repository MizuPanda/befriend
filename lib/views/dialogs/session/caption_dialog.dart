import 'package:flutter/material.dart';

class CaptionDialog {
  static Future<String?> showCaptionDialog(
    BuildContext context,
    int characterLimit,
  ) {
    TextEditingController captionController = TextEditingController();

    return showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            actionsAlignment: MainAxisAlignment.spaceEvenly,
            title: const Text('Enter a Caption'),
            content: TextField(
              controller: captionController,
              decoration: InputDecoration(
                hintText: "Caption for the picture",
                counterText:
                    'Characters limit: $characterLimit', // Optional: Hide the counter text
              ),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              maxLength: characterLimit, // Enforces the character limit
            ),
            actions: [
              TextButton(
                child: const Text(
                  'Cancel',
                  textAlign: TextAlign.end,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text(
                  'Publish',
                  textAlign: TextAlign.end,
                ),
                onPressed: () {
                  Navigator.of(context).pop(captionController.text.trim());
                },
              ),
            ],
          );
        });
  }
}
