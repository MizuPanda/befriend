import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../providers/hosting_provider.dart';
import '../../../../utilities/constants.dart';
import '../../users/profile_photo.dart';

class HostingColumn extends StatefulWidget {
  const HostingColumn({super.key});

  @override
  State<HostingColumn> createState() => _HostingColumnState();
}

class _HostingColumnState extends State<HostingColumn> {
  @override
  Widget build(BuildContext context) {
    return Consumer<HostingProvider>(builder:
        (BuildContext context, HostingProvider provider, Widget? child) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 5,
          ),
          SizedBox(
            width: Constants.pictureDialogWidth - 100,
            child: Text(
              '${provider.hostUsername()} will take a picture!',
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(
                  textStyle: const TextStyle(
                fontSize: 20,
              )),
              maxLines: 2,
            ),
          ),
          Expanded(
              child: ListView.builder(
            itemCount: provider.length(),
            itemBuilder: (context, index) {
              return Builder(builder: (context) {
                if (provider.isMain() && index != 0) {
                  return ListTile(
                    leading: ProfilePhoto(
                      user: provider.bubble(index),
                      radius: Constants.pictureDialogAvatarSize,
                    ),
                    title: Text(provider.username(index)),
                    trailing: IconButton(
                      onPressed: () async {
                        await provider.deleteUser(index);
                      },
                      icon: const Icon(
                        Icons.delete_rounded,
                        color: Colors.red,
                      ),
                    ),
                  );
                } else {
                  return ListTile(
                    leading: ProfilePhoto(
                      user: provider.bubble(index),
                      radius: Constants.pictureDialogAvatarSize,
                    ),
                    title: Text(provider.username(index)),
                  );
                }
              });
            },
          )),
          if (provider.isMain())
            Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(10),
              child: TextButton(
                onPressed: provider.length() >= 2
                    ? () async {
                        await provider.startSession();
                      }
                    : null,
                child: Text(
                  'Take the picture',
                  style: GoogleFonts.openSans(
                      textStyle: const TextStyle(fontSize: 16)),
                ),
              ),
            )
        ],
      );
    });
  }
}
