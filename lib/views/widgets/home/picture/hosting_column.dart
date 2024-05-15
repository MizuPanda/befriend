import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../providers/hosting_provider.dart';
import '../../../../utilities/constants.dart';
import '../../users/profile_photo.dart';

class HostingColumn extends StatelessWidget {
  const HostingColumn({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HostingProvider>(builder:
        (BuildContext context, HostingProvider provider, Widget? child) {
      return ListView.builder(
        itemCount: provider.length(),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: ListTile(
              leading: ProfilePhoto(
                user: provider.bubble(index),
                radius: Constants.pictureDialogAvatarSize,
              ),
              title: AutoSizeText(provider.username(index)),
              trailing: (provider.isMain() && index != 0)
                  ? IconButton(
                      onPressed: () async {
                        await provider.deleteUser(index);
                      },
                      icon: const Icon(
                        Icons.delete_rounded,
                        color: Colors.red,
                      ),
                    )
                  : null,
            ),
          );
        },
      );
    });
  }
}
