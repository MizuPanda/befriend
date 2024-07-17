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
          Row(children: [
            Padding(
              padding: EdgeInsets.only(left: 8.0 / 448 * width),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AutoSizeText(
                    profile.user.main()
                        ? '${AppLocalizations.of(context)?.translate('prfs_fs') ?? 'Friendship Score'}: ${profile.user.power}'
                        : '${AppLocalizations.of(context)?.translate('prfs_fl') ?? 'Friendship Level'}: ${profile.friendship!.level}',
                    style: GoogleFonts.openSans(
                      textStyle: const TextStyle(
                        fontSize: 18,
                      ),
                    )),
              ),
            ),
            const Spacer(),

          ],),
          if (!profile.user.main())
            Padding(
              padding: EdgeInsets.only(left: 8.0 / 448 * width),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: AutoSizeText(
                    '${AppLocalizations.of(context)?.translate('prfs_since')?? 'Friends since'} ${timeago.format(profile.friendship?.created?? DateTime.now())}',
                    textAlign: TextAlign.start,
                    style: GoogleFonts.openSans(textStyle: const TextStyle(fontSize: 18)),
                  )),
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
                                      '${AppLocalizations.of(context)?.translate('prfs_followed') ?? 'Followed by'} '),
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
