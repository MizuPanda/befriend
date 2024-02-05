import 'package:befriend/providers/profile_provider.dart';
import 'package:befriend/views/widgets/befriend_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/objects/profile.dart';
import '../widgets/profile/header.dart';
import '../widgets/profile/pictures.dart';
import '../widgets/profile/state.dart';

class ProfilePage extends StatelessWidget {
  final Profile profile;

  const ProfilePage({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const BefriendTitle(),
          foregroundColor: Colors.black,
          backgroundColor: Colors.white),
      body: ChangeNotifierProvider(
        create: (_) => ProfileProvider(),
        builder: (BuildContext context, Widget? child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SafeArea(
                minimum: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileHeader(
                      profile: profile,
                    ),
                    const SizedBox(height: 16),
                    ProfileState(profile: profile,),
                  ],
                ),
              ),
               Padding(
                padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                child: Text(
                  'Pictures',
                  style: GoogleFonts.openSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                )),
              ),
              Expanded(
                child: ProfilePictures(
                  user: profile.user,
                ),
              ),
            ],
          );
        }
      ),
    );
  }
}
