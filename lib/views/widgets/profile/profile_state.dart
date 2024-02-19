import 'package:befriend/providers/profile_provider.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../models/objects/profile.dart';
import '../users/progress_bar.dart';

class ProfileState extends StatelessWidget {
  const ProfileState({
    super.key,
    required this.profile,
  });

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(builder:
        (BuildContext context, ProfileProvider provider, Widget? child) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(profile.levelText(),
                  style: GoogleFonts.firaMono(
                    textStyle:
                        const TextStyle(fontSize: 16, color: Colors.black),
                  )),
            ),
          ),
          if (!profile.user.main())
            Column(
              children: [
                const SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: ProgressBar(
                    progress: profile.friendship!.progress,
                  ),
                ),
                if (!provider.areUsernamesEmpty())
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                        style: ButtonStyle(
                          overlayColor: MaterialStateProperty.all(
                              Colors.transparent), // Removes splash effect
                        ),
                        onPressed: () async {
                          if (context.mounted) {
                            GoRouter.of(context)
                                .push(Constants.mutualAddress, extra: profile);
                          }
                        },
                        child: Text.rich(TextSpan(
                            style: GoogleFonts.openSans(
                                fontSize: 13, color: Colors.black),
                            children: [
                              const TextSpan(text: 'Followed by '),
                              TextSpan(
                                  text: provider.friendsInCommon(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold))
                            ]))),
                  ),
              ],
            ),
        ],
      );
    });
  }
}
