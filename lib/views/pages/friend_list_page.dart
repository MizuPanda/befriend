import 'package:auto_size_text/auto_size_text.dart';
import 'package:befriend/models/objects/friendship.dart';
import 'package:befriend/providers/friend_list_provider.dart';
import 'package:befriend/utilities/decorations.dart';
import 'package:befriend/views/widgets/users/profile_photo.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

import '../../models/objects/bubble.dart';
import '../../providers/material_provider.dart';
import '../../utilities/app_localizations.dart';
import '../widgets/users/progress_bar.dart';

class FriendsListPage extends StatefulWidget {
  const FriendsListPage({
    super.key,
    required this.user,
  });

  @override
  State<FriendsListPage> createState() => _FriendsListPageState();

  final Bubble user;
}

class _FriendsListPageState extends State<FriendsListPage> {
  late final FriendListProvider _provider = FriendListProvider();

  @override
  void initState() {
    super.initState();
    if (widget.user.hasFriends()) {
      _provider.initState(mainUser: widget.user);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _provider.disposeState();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)?.translate('flp_list') ??
                  'Friends List',
              style: GoogleFonts.openSans(),
            ),
            const SizedBox(
              width: 5,
            ),
            const Icon(Icons.people_outline_rounded),
          ],
        ),
      ),
      body: ChangeNotifierProvider.value(
        value: _provider,
        builder: (BuildContext context, Widget? child) {
          return Consumer<FriendListProvider>(
            builder: (BuildContext context, FriendListProvider provider,
                Widget? child) {
              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(width * 0.02),
                    child: TextField(
                      controller: provider.searchController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: AppLocalizations.of(context)
                                ?.translate('flp_search') ??
                            'Search by username',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: widget.user.hasFriends()
                        ? PagedListView<int, Friendship>(
                            pagingController: provider.pagingController,
                            builderDelegate:
                                PagedChildBuilderDelegate<Friendship>(
                              noItemsFoundIndicatorBuilder:
                                  (BuildContext context) {
                                return Center(
                                  child: Text(AppLocalizations.of(context)
                                          ?.translate('flp_no') ??
                                      'No friends found'),
                                );
                              },
                              itemBuilder: (context, friendship, index) {
                                return Padding(
                                  padding: EdgeInsets.all(width * 0.02),
                                  child: InkWell(
                                    onTap: () {
                                      provider.goToFriendProfile(
                                          context, friendship, widget.user);
                                    },
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Consumer<MaterialProvider>(
                                              builder: (BuildContext context,
                                                  MaterialProvider
                                                      materialProvider,
                                                  Widget? child) {
                                                return Container(
                                                  decoration: Decorations
                                                      .bubbleDecoration(
                                                          materialProvider
                                                              .isLightMode(
                                                                  context)),
                                                  child: ProfilePhoto(
                                                    user: friendship.friend,
                                                    radius: 0.1 * width,
                                                  ),
                                                );
                                              },
                                            ),
                                            SizedBox(
                                              width: 0.03 * width,
                                            ),
                                            AutoSizeText(
                                              '@${friendship.friend.username}',
                                              style: GoogleFonts.openSans(
                                                fontSize: 20,
                                              ),
                                            ),
                                            const Spacer(),
                                            AutoSizeText(
                                              '${AppLocalizations.of(context)?.translate('flp_lvl') ?? 'LVL'}${friendship.level}',
                                              style: GoogleFonts.openSans(),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 0.015 * height,
                                        ),
                                        ProgressBar(
                                          progress: friendship.progress,
                                          isBestFriend: friendship.isBestFriend,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : Center(
                            child: Text(AppLocalizations.of(context)
                                    ?.translate('flp_yet') ??
                                "You don't have friends yet."),
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
