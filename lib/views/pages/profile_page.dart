import 'package:befriend/providers/profile_provider.dart';
import 'package:befriend/views/widgets/befriend_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/objects/profile.dart';
import '../widgets/profile/profile_header.dart';
import '../widgets/profile/profile_pictures.dart';
import '../widgets/profile/profile_state.dart';

class ProfilePage extends StatelessWidget {
  final Profile profile;

  const ProfilePage({super.key, required this.profile});

  static const double padding = 16.0;
  static const double _iconTextDistance = 5.0;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => ProfileProvider(profile: profile),
        builder: (BuildContext context, Widget? child) {
          final double height = MediaQuery.of(context).size.height;

          return Scaffold(
            appBar: AppBar(
              title: const BefriendTitle(),
              actions: !profile.user.main()
                  ? [
                      Consumer(builder: (BuildContext context,
                          ProfileProvider provider, Widget? child) {
                        return PopupMenuButton<int>(
                            icon: const Icon(
                              Icons.more_vert,
                            ),
                            onSelected: (int selection) async {
                              await provider.onSelectMenu(selection, context);
                            },
                            itemBuilder: (BuildContext context) => [
                                  const PopupMenuItem<int>(
                                    value: 0,
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete_outline_rounded,
                                            color: Colors.red), // Archive icon
                                        SizedBox(width: _iconTextDistance),
                                        Text(
                                          'Delete this user',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        SizedBox(width: _iconTextDistance * 2),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem<int>(
                                    value: 1,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.block_rounded,
                                        ), // Info icon
                                        SizedBox(width: _iconTextDistance),
                                        Text('Block this user'),
                                        SizedBox(width: _iconTextDistance * 2),
                                      ],
                                    ),
                                  ),
                                ]);
                      })
                    ]
                  : null,
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: padding, left: padding, right: padding),
                  child: ProfileHeader(
                    profile: profile,
                  ),
                ),
                SizedBox(height: 0.016 * height),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: padding),
                  child: ProfileState(
                    profile: profile,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: padding, bottom: 8.0),
                  child: Text('Pictures',
                      style: GoogleFonts.openSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      )),
                ),
                Expanded(
                  child: ProfilePictures(
                    userID: profile.user.id,
                    showArchived: false,
                  ),
                ),
              ],
            ),
          );
        });
  }
}
