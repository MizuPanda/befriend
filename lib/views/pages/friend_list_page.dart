import 'package:befriend/models/objects/friendship.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:befriend/utilities/decorations.dart';
import 'package:befriend/views/widgets/users/profile_photo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../models/data/data_manager.dart';
import '../../models/objects/bubble.dart';
import '../widgets/users/progress_bar.dart';

class FriendsListPage extends StatefulWidget {
  const FriendsListPage({super.key, required this.user});

  @override
  State<FriendsListPage> createState() => _FriendsListPageState();

  final Bubble user;
}

class _FriendsListPageState extends State<FriendsListPage> {
  static const _pageSize = 10;
  final PagingController<int, Friendship> _pagingController =
      PagingController(firstPageKey: 0);
  DocumentSnapshot? _lastDocument;

  @override
  void initState() {
    super.initState();

    // Preload initial friends into the PagingController.
    final List<Friendship> initialFriends = widget.user.friendships;
    if (initialFriends.isNotEmpty) {
      _pagingController.itemList = initialFriends;
    }

    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      List<Friendship> friendships = [];

      if (widget.user.hasNonLoadedFriends()) {
        debugPrint('(FriendListPage): Has non loaded friendships');
        final String userId = widget.user.id;

        if (pageKey == 0 || _lastDocument == null) {
          _lastDocument ??= await widget.user.getLastFriendshipDocument();
        }

        QuerySnapshot querySnapshot = await Constants.friendshipsCollection
            .where(Filter.or(
              Filter(
                Constants.user1Doc,
                isEqualTo: userId,
              ),
              Filter(
                Constants.user2Doc,
                isEqualTo: userId,
              ),
            ))
            .orderBy(Constants.levelDoc, descending: true)
            .startAfterDocument(_lastDocument!)
            .limit(_pageSize)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          _lastDocument = querySnapshot.docs.last;
        }

        for (QueryDocumentSnapshot snapshot in querySnapshot.docs) {
          String user1 = DataManager.getString(snapshot, Constants.user1Doc);
          String user2 = DataManager.getString(snapshot, Constants.user2Doc);
          String friendId;
          Bubble friend;

          if (user1 == userId) {
            friendId = user2;
          } else {
            friendId = user1;
          }

          DocumentSnapshot bubbleSnapshot =
              await DataManager.getData(id: friendId);
          ImageProvider bubbleImage =
              await DataManager.getAvatar(bubbleSnapshot);

          friend = Bubble.fromDocsWithoutFriends(bubbleSnapshot, bubbleImage);

          Friendship friendship = Friendship.fromDocs(userId, friend, snapshot);
          friendships.add(friendship);
        }
      }

      final List<Friendship> newItems = friendships;
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final int nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
      debugPrint('(FriendListPage): Error = $error');
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: PagedListView<int, Friendship>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<Friendship>(
            itemBuilder: (context, friendship, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                        decoration: Decorations.bubbleDecoration,
                        child: ProfilePhoto(
                          user: friendship.friend,
                          radius: 40,
                        )),
                    const SizedBox(
                      width: 12,
                    ),
                    Column(
                      children: [
                        Text(
                          friendship.friend.username,
                          style: GoogleFonts.openSans(fontSize: 16),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          '@${friendship.friend.username}',
                          style: GoogleFonts.openSans(
                              fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      'LVL${friendship.level}',
                      style: GoogleFonts.openSans(),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                ProgressBar(
                  progress: friendship.progress,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
