import 'package:auto_size_text/auto_size_text.dart';
import 'package:befriend/models/data/data_query.dart';
import 'package:befriend/models/data/user_manager.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:befriend/utilities/error_handling.dart';
import 'package:befriend/views/dialogs/settings/unblock_dialog.dart';
import 'package:flutter/material.dart';

import '../../../models/objects/bubble.dart';

class BlockedSettingsWidget extends StatefulWidget {
  const BlockedSettingsWidget({
    super.key,
  });

  @override
  State<BlockedSettingsWidget> createState() => _BlockedSettingsWidgetState();
}

class _BlockedSettingsWidgetState extends State<BlockedSettingsWidget> {
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text(
              "Blocked accounts ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Icon(Icons.supervisor_account_rounded)
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.0 / 448 * width),
        child: FutureBuilder(
            future: UserManager.getInstance(),
            builder: (
              BuildContext context,
              AsyncSnapshot<Bubble> instance,
            ) {
              if (!instance.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              Bubble bubble = instance.data!;
              Iterable<dynamic> usernames = bubble.blockedUsers.values;

              return ListView.builder(
                  itemCount: usernames.length,
                  itemBuilder: (BuildContext context, int index) {
                    String username = usernames.elementAt(index);
                    return SizedBox(
                      child: Row(
                        children: [
                          const Icon(Icons.person),
                          SizedBox(
                            width: 20 / 448 * width,
                          ),
                          AutoSizeText(username,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          TextButton(
                              onPressed: () async {
                                UnblockDialog.showUnblockDialog(
                                  context,
                                  username,
                                  () async {
                                    try {
                                      bubble.blockedUsers.remove(bubble
                                          .blockedUsers.entries
                                          .elementAt(index)
                                          .key);
                                      await DataQuery.updateDocument(
                                          Constants.blockedUsersDoc,
                                          bubble.blockedUsers);
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((timeStamp) {
                                        setState(() {});
                                      });
                                    } catch (e) {
                                      debugPrint(
                                          '(BlockedSettingsWidget): Error: $e');
                                      if (context.mounted) {
                                        ErrorHandling.showError(context,
                                            'An unexpected error occurred. Please try again.');
                                      }
                                    }
                                  },
                                );
                              },
                              child: const Text('Unblock'))
                        ],
                      ),
                    );
                  });
            }),
      ),
    );
  }
}
