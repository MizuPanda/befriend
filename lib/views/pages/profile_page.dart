import 'package:auto_size_text/auto_size_text.dart';
import 'package:befriend/providers/profile_provider.dart';
import 'package:befriend/views/widgets/befriend_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/objects/profile.dart';
import '../../utilities/app_localizations.dart';
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
        final double width = MediaQuery.of(context).size.width;

        if (profile.user.main()) {
          return DefaultTabController(
            length: 2, // Number of tabs
            initialIndex: profile.initialIndex,
            child: Scaffold(
              appBar: AppBar(
                title: const BefriendTitle(),
              ),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: padding, left: padding, right: padding),
                    child: ProfileHeader(profile: profile),
                  ),
                  SizedBox(height: 0.016 * height),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: padding),
                    child: ProfileState(profile: profile),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: padding, bottom: 8.0),
                    child: Text(
                      AppLocalizations.of(context)?.translate('pp_feed') ??
                          'My Feed',
                      style: GoogleFonts.openSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // TabBar
                  const TabBar(
                    tabs: [
                      Tab(
                        icon: Icon(Icons.person),
                      ),
                      Tab(
                        icon: Icon(Icons.people),
                      ),
                    ],
                  ),
                  // Expanded TabBarView
                  Expanded(
                    child: TabBarView(
                      children: [
                        ProfilePictures(
                          userID: profile.user.id,
                          showArchived: false,
                          showOnlyMe: true,
                        ),
                        ProfilePictures(
                          userID: profile.user.id,
                          showArchived: false,
                          showOnlyMe: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
                title: const BefriendTitle(),
                actions: !profile.isLocked
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
                                    PopupMenuItem<int>(
                                      value: 0,
                                      child: Row(
                                        children: [
                                          const Icon(
                                              Icons.delete_outline_rounded,
                                              color:
                                                  Colors.red), // Archive icon
                                          const SizedBox(
                                              width: _iconTextDistance),
                                          Text(
                                            AppLocalizations.of(context)
                                                    ?.translate('pp_delete') ??
                                                'Delete',
                                            style: const TextStyle(
                                                color: Colors.red),
                                          ),
                                          const SizedBox(
                                              width: _iconTextDistance * 2),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem<int>(
                                      value: 1,
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.block_rounded,
                                          ), // Info icon
                                          const SizedBox(
                                              width: _iconTextDistance),
                                          Text(AppLocalizations.of(context)
                                                  ?.translate('pp_block') ??
                                              'Block'),
                                          const SizedBox(
                                              width: _iconTextDistance * 2),
                                        ],
                                      ),
                                    ),
                                  ]);
                        })
                      ]
                    : null),
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
                  padding:
                      EdgeInsets.only(left: padding, bottom: 0.008 * height),
                  child: Text(
                      AppLocalizations.of(context)?.translate('pp_pictures') ??
                          'Pictures',
                      style: GoogleFonts.openSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      )),
                ),
                Expanded(
                  child: profile.isLocked
                      ? Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.0 / 448 * width),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AutoSizeText(
                                '${AppLocalizations.of(context)?.translate('pp_need') ?? 'You need to add'} ${profile.user.username} ${AppLocalizations.of(context)?.translate('pp_friend') ?? 'as a friend to see their pictures.'}',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.openSans(
                                  fontSize: 17,
                                ),
                              ),
                              AutoSizeText(
                                AppLocalizations.of(context)
                                        ?.translate('pp_become') ??
                                    'Take a picture with them or send them your invite link to become friends',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.openSans(
                                    fontSize: 15, color: Colors.grey),
                              ),
                              SizedBox(
                                height: 0.1 * height,
                              ),
                            ],
                          ),
                        )
                      : ProfilePictures(
                          userID: profile.user.id,
                          showArchived: false,
                          showOnlyMe: false,
                        ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
