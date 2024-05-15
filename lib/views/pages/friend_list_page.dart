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
  final FriendListProvider _provider = FriendListProvider();

  @override
  void initState() {
    super.initState();
    _provider.initState(widget.user.friendships,
        hasNonLoadedFriends: widget.user.hasNonLoadedFriends(),
        lastFriendshipDocument: widget.user.getLastFriendshipDocument(),
        id: widget.user.id);
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
                'Friends List',
                style: GoogleFonts.openSans(),
              ),
              const SizedBox(
                width: 5,
              ),
              const Icon(Icons.people_outline_rounded),
            ],
          )),
      body: ChangeNotifierProvider.value(
          value: _provider,
          builder: (BuildContext context, Widget? child) {
            return Consumer(builder: (BuildContext context,
                FriendListProvider provider, Widget? child) {
              return PagedListView<int, Friendship>(
                pagingController: provider.pagingController,
                builderDelegate: PagedChildBuilderDelegate<Friendship>(
                    noItemsFoundIndicatorBuilder: (BuildContext context) {
                  return const Center();
                }, itemBuilder: (context, friendship, index) {
                  return Padding(
                    padding: EdgeInsets.all(width * 0.02),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Consumer(builder: (BuildContext context,
                                MaterialProvider materialProvider,
                                Widget? child) {
                              return Container(
                                  decoration: Decorations.bubbleDecoration(
                                      materialProvider.isLightMode(context)),
                                  child: ProfilePhoto(
                                    user: friendship.friend,
                                    radius: 0.1 * width,
                                  ));
                            }),
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
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(
                                  height: 0.02 * height,
                                ),
                                AutoSizeText(
                                  'LVL${friendship.level}',
                                  style: GoogleFonts.openSans(),
                                ),
                                IconButton(
                                    onPressed: () {
                                      provider.goToFriendProfile(
                                          context, friendship, widget.user);
                                    },
                                    icon: const Icon(Icons.house_rounded)),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 0.015 * height,
                        ),
                        ProgressBar(
                          progress: friendship.progress,
                        ),
                      ],
                    ),
                  );
                }),
              );
            });
          }),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _provider.disposeState();
  }
}
