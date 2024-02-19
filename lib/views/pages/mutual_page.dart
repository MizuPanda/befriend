import 'package:befriend/models/data/data_manager.dart';
import 'package:befriend/models/objects/bubble.dart';
import 'package:befriend/models/objects/friendship.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../models/objects/profile.dart';

class MutualPage extends StatefulWidget {
  const MutualPage({
    super.key,
    required this.profile,
  });

  @override
  State<MutualPage> createState() => _MutualPageState();

  final Profile profile;
}

class _MutualPageState extends State<MutualPage> {
  List<Bubble> filteredUsers = [];
  List<Bubble> _allLoadedUsers = [];

  DocumentSnapshot? _lastDocument;

  final PagingController<int, Bubble> _pagingController =
      PagingController(firstPageKey: 0);
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();

    _pagingController.itemList = widget.profile.commonFriends;
    _allLoadedUsers = widget.profile.commonFriends;

    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
      _allLoadedUsers = _pagingController.itemList!;
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    final List<Friendship> moreFriends = [];

    String currentUserId = widget.profile.currentUser.id;

    if (widget.profile.currentUser.hasNonLoadedFriends()) {
      if (_lastDocument == null || pageKey == 0) {
        _lastDocument ??=
            await widget.profile.currentUser.getLastFriendshipDocument();
      }

      // Your Firestore query to fetch more friends, starting after the last document
      QuerySnapshot querySnapshot = await Constants.friendshipsCollection
          .where(Filter.or(
            Filter(
              Constants.user1Doc,
              isEqualTo: currentUserId,
            ),
            Filter(
              Constants.user2Doc,
              isEqualTo: currentUserId,
            ),
          ))
          .orderBy(Constants.levelDoc, descending: true)
          .startAfterDocument(_lastDocument!)
          .limit(_pageSize)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        _lastDocument = querySnapshot.docs.last;
        for (QueryDocumentSnapshot snapshot in querySnapshot.docs) {
          String user1 = DataManager.getString(snapshot, Constants.user1Doc);
          String user2 = DataManager.getString(snapshot, Constants.user2Doc);
          String friendId;
          Bubble friend;
          if (user1 == currentUserId) {
            friendId = user2;
          } else {
            friendId = user1;
          }
          DocumentSnapshot bubbleSnapshot =
              await DataManager.getData(id: friendId);
          ImageProvider bubbleImage =
              await DataManager.getAvatar(bubbleSnapshot);

          friend = Bubble.fromDocsWithoutFriends(bubbleSnapshot, bubbleImage);

          Friendship friendship =
              Friendship.fromDocs(currentUserId, friend, snapshot);
          moreFriends.add(friendship);
        }
      }
    }

    final List<Bubble> newItems = moreFriends.map((e) => e.friend).toList();
    final isLastPage = newItems.length < _pageSize;
    if (isLastPage) {
      _pagingController.appendLastPage(newItems);
    } else {
      final int nextPageKey = pageKey + newItems.length;
      _pagingController.appendPage(newItems, nextPageKey);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _filterUsers(String searchTerm) {
    final lowerCaseSearchTerm = searchTerm.toLowerCase();

    filteredUsers = _allLoadedUsers.where((user) {
      return user.username.toLowerCase().contains(lowerCaseSearchTerm) ||
          user.name.toLowerCase().contains(lowerCaseSearchTerm);
    }).toList();

    setState(() {
      _isSearching = searchTerm.isNotEmpty;
    });
  }

  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mutual'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _filterUsers,
              decoration: InputDecoration(
                labelText: 'Search',
                suffixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isSearching
                ? ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user.avatar,
                        ),
                        title: Text(user.username),
                        subtitle: Text(user.name),
                      );
                    },
                  )
                : PagedListView<int, Bubble>(
                    pagingController: _pagingController,
                    builderDelegate: PagedChildBuilderDelegate<Bubble>(
                      itemBuilder: (context, item, index) => ListTile(
                        leading: CircleAvatar(
                          backgroundImage: item.avatar,
                        ),
                        title: Text(item.username),
                        subtitle: Text(item.name),
                      ),
                    ),
                    /*
            ListView.builder(
              controller: _scrollController,
              itemCount: filteredUsers.length
              itemBuilder: (context, index) {

                final user = filteredUsers[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: user.avatar,
                  ),
                  title: Text(user.username),
                  subtitle: Text(user.name),
                );
              },

             */
                  ),
          ),
        ],
      ),
    );
  }
}
