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

class ProfilePage extends StatefulWidget {
  final Profile profile;

  const ProfilePage({super.key, required this.profile});

  static const double padding = 16.0;
  static const double _iconTextDistance = 5.0;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileProvider _provider =
      ProfileProvider(profile: widget.profile);

  @override
  void initState() {
    _provider.resetStreak(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      builder: (BuildContext context, Widget? child) {
        final double height = MediaQuery.of(context).size.height;

        if (widget.profile.user.main()) {
          return DefaultTabController(
            length: 2, // Number of tabs
            initialIndex: widget.profile.initialIndex,
            child: Scaffold(
              appBar: AppBar(
                title: const BefriendTitle(),
              ),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: ProfilePage.padding,
                        left: ProfilePage.padding,
                        right: ProfilePage.padding),
                    child: ProfileHeader(profile: widget.profile),
                  ),
                  SizedBox(height: 0.016 * height),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: ProfilePage.padding),
                    child: ProfileState(profile: widget.profile),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: ProfilePage.padding, bottom: 8.0),
                    child: Text(
                      AppLocalizations.translate(context,
                          key: 'pp_feed', defaultString: 'My Feed'),
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
                          profileUsername: widget.profile.user.username,
                          userID: widget.profile.user.id,
                          showArchived: false,
                          showOnlyMe: true,
                          isLocked: false,
                        ),
                        ProfilePictures(
                          profileUsername: widget.profile.user.username,
                          userID: widget.profile.user.id,
                          showArchived: false,
                          showOnlyMe: false,
                          isLocked: false,
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
            appBar: AppBar(title: const BefriendTitle(), actions: [
              Consumer(builder: (BuildContext context, ProfileProvider provider,
                  Widget? child) {
                return PopupMenuButton<int>(
                    icon: const Icon(
                      Icons.more_vert,
                    ),
                    onSelected: (int selection) async {
                      await provider.onSelectMenu(selection, context);
                    },
                    itemBuilder: (BuildContext context) => [
                          if (!widget.profile.isLocked)
                            PopupMenuItem<int>(
                              value: 0,
                              child: Row(
                                children: [
                                  const Icon(Icons.delete_outline_rounded,
                                      color: Colors.red), // Archive icon
                                  const SizedBox(
                                      width: ProfilePage._iconTextDistance),
                                  Text(
                                    AppLocalizations.translate(context,
                                        key: 'pp_delete',
                                        defaultString: 'Delete'),
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                  const SizedBox(
                                      width: ProfilePage._iconTextDistance * 2),
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
                                    width: ProfilePage._iconTextDistance),
                                Text(AppLocalizations.translate(context,
                                    key: 'pp_block', defaultString: 'Block')),
                                const SizedBox(
                                    width: ProfilePage._iconTextDistance * 2),
                              ],
                            ),
                          ),
                        ]);
              })
            ]),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: ProfilePage.padding,
                      left: ProfilePage.padding,
                      right: ProfilePage.padding),
                  child: ProfileHeader(
                    profile: widget.profile,
                  ),
                ),
                SizedBox(height: 0.016 * height),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: ProfilePage.padding),
                  child: ProfileState(
                    profile: widget.profile,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: ProfilePage.padding, bottom: 0.008 * height),
                  child: Text(
                      AppLocalizations.translate(context,
                          key: 'pp_pictures', defaultString: 'Pictures'),
                      style: GoogleFonts.openSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      )),
                ),
                Expanded(
                  child: ProfilePictures(
                    profileUsername: widget.profile.user.username,
                    userID: widget.profile.user.id,
                    showArchived: false,
                    showOnlyMe: false,
                    isLocked: widget.profile.isLocked,
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
