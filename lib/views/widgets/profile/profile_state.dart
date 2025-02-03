import 'package:auto_size_text/auto_size_text.dart';
import 'package:befriend/providers/profile_provider.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../models/objects/profile.dart';
import '../../../utilities/app_localizations.dart';
import '../users/progress_bar.dart';
import 'package:timeago/timeago.dart' as timeago;

class ProfileState extends StatelessWidget {
  const ProfileState({
    super.key,
    required this.profile,
  });

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Consumer<ProfileProvider>(builder:
        (BuildContext context, ProfileProvider provider, Widget? child) {
      return Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 8.0 / 448 * width),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AutoSizeText(
                      profile.user.main()
                          ? '${AppLocalizations.translate(context, key: 'prfs_fs', defaultString: 'Friendship Score')}: ${profile.user.power}'
                          : '${AppLocalizations.translate(context, key: 'prfs_fl', defaultString: 'Friendship Level')}: ${profile.friendship!.level}',
                      style: GoogleFonts.openSans(
                        textStyle: const TextStyle(
                          fontSize: 18,
                        ),
                      )),
                ),
              ),
              const Spacer(),
              if (profile.friendship?.isBestFriend ?? false)
                AutoSizeText(
                  AppLocalizations.translate(context,
                      key: "prfs_best", defaultString: "Your Best Friend"),
                  style: GoogleFonts.openSans(
                      textStyle: const TextStyle(
                    fontSize: 18,
                  )),
                )
            ],
          ),
          if (!profile.user.main() && profile.friendship != null)
            Padding(
              padding: EdgeInsets.only(left: 8.0 / 448 * width),
              child: SizedBox(
                width: double.infinity,
                child: AutoSizeText(
                  '${AppLocalizations.translate(context, key: 'prfs_since', defaultString: 'Since')} ${timeago.format(profile.friendship!.created)}',
                  textAlign: TextAlign.start,
                  style: GoogleFonts.openSans(
                      textStyle: const TextStyle(fontSize: 18)),
                ),
              ),
            ),
          if (!profile.user.main())
            Column(
              children: [
                SizedBox(
                  height: 0.005 * height,
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 0.005 * height),
                  child: ProgressBar(
                    progress: profile.friendship!.progress,
                    isBestFriend: profile.friendship!.isBestFriend,
                  ),
                ),
                if (!provider.areUsernamesEmpty())
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                        style: ButtonStyle(
                          overlayColor: WidgetStateProperty.all(
                              Colors.transparent), // Removes splash effect
                        ),
                        onPressed: () async {
                          if (context.mounted) {
                            GoRouter.of(context)
                                .push(Constants.mutualAddress, extra: profile);
                          }
                        },
                        child: AutoSizeText.rich(TextSpan(
                            style: GoogleFonts.openSans(
                              fontSize: 13,
                            ),
                            children: [
                              TextSpan(
                                  text:
                                      '${AppLocalizations.translate(context, key: 'prfs_followed', defaultString: 'Followed by')} '),
                              TextSpan(
                                  text: provider.friendsInCommon(context),
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
