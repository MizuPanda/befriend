import 'package:befriend/models/data/data_query.dart';
import 'package:befriend/models/data/user_manager.dart';
import 'package:befriend/utilities/constants.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text("Blocked accounts"),
            Icon(Icons.supervisor_account_rounded)
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
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
                          const SizedBox(
                            width: 20,
                          ),
                          Text(username,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          TextButton(
                              onPressed: () async {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext dialogContext) {
                                    return AlertDialog(
                                      title: Text(
                                        'Unblock $username',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      content: Text(
                                          "Are you sure you want to unblock $username?",
                                          style: const TextStyle(fontSize: 16)),
                                      actions: [
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
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            bubble.blockedUsers.remove(bubble
                                                .blockedUsers.entries
                                                .elementAt(index)
                                                .key);
                                            await DataQuery.updateDocument(
                                                Constants.blockedUsersDoc,
                                                bubble.blockedUsers);
                                            if (context.mounted) {
                                              Navigator.of(dialogContext)
                                                  .pop(); // Dismiss the dialog
                                            }
                                            WidgetsBinding.instance
                                                .addPostFrameCallback(
                                                    (timeStamp) {
                                              setState(() {});
                                            });
                                          },
                                          child: const Text('Unblock',
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 15)),
                                        ),
                                      ],
                                    );
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
