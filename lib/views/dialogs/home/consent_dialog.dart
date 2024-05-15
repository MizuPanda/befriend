import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ConsentDialog {
  static void showConsentDialog(
      BuildContext context, String dialogName, String fileAddress) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(dialogName),
          content: FutureBuilder(
            future: DefaultAssetBundle.of(context).loadString(fileAddress),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasData) {
                return SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: Markdown(data: snapshot.data ?? ''));
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
