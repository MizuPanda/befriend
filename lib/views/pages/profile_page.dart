import 'package:befriend/models/data/user_manager.dart';
import 'package:befriend/providers/profile_provider.dart';
import 'package:befriend/views/widgets/befriend_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/objects/bubble.dart';
import '../../models/objects/profile.dart';
import '../widgets/profile/header.dart';
import '../widgets/profile/profile_pictures.dart';
import '../widgets/profile/profile_state.dart';

class ProfilePage extends StatelessWidget {
  final Profile profile;

  const ProfilePage({super.key, required this.profile});

  static const double padding = 16.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const BefriendTitle(),
          foregroundColor: Colors.black,
          backgroundColor: Colors.white),
      body: FutureBuilder(
          future: UserManager.getInstance(),
          builder: (
            BuildContext context,
            AsyncSnapshot<Bubble> bubble,
          ) {
            if (!bubble.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return ChangeNotifierProvider(
                create: (_) => ProfileProvider.initializeCommonFriends(
                    profile, bubble.data!),
                builder: (BuildContext context, Widget? child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: padding, left: padding, right: padding),
                        child: ProfileHeader(
                          profile: profile,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: padding),
                        child: ProfileState(
                          profile: profile,
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: padding, bottom: 8.0),
                        child: Text('Pictures',
                            style: GoogleFonts.openSans(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                      Expanded(
                        child: ProfilePictures(
                          userID: profile.user.id,
                        ),
                      ),
                    ],
                  );
                });
          }),
    );
  }
}
