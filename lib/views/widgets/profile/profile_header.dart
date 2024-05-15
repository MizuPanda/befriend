import 'package:auto_size_text/auto_size_text.dart';
import 'package:befriend/providers/profile_provider.dart';
import 'package:befriend/utilities/decorations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../models/objects/profile.dart';
import '../../../providers/material_provider.dart';
import '../users/profile_photo.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.profile,
  });

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Consumer<ProfileProvider>(builder:
        (BuildContext context, ProfileProvider provider, Widget? child) {
      return Stack(
        children: [
          Row(
            children: [
              Consumer(builder: (BuildContext context,
                  MaterialProvider materialProvider, Widget? child) {
                final bool isLightMode = materialProvider.isLightMode(context);

                return Container(
                    decoration: Decorations.bubbleDecoration(isLightMode),
                    child: ProfilePhoto(
                      radius: 50,
                      user: profile.user,
                    ));
              }),
              SizedBox(width: 16 / 448 * width),
              Expanded(
                child: AutoSizeText(
                  '@${profile.user.username}',
                  style: GoogleFonts.openSans(
                      fontSize: 20.0, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (profile.user.main())
            Positioned(
              left: 90,
              child: IconButton(
                onPressed: () {
                  provider.showEditProfileDialog(context, profile.user, () {
                    profile.notifyParent();
                  });
                },
                icon: const Icon(
                  Icons.mode_edit_outline_outlined,
                  size: 30,
                ),
              ),
            ),
        ],
      );
    });
  }
}
