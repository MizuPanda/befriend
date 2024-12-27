import 'package:befriend/models/data/data_query.dart';
import 'package:befriend/models/data/user_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../models/data/data_manager.dart';
import '../models/objects/bubble.dart';
import '../models/objects/friendship.dart';
import '../models/objects/profile.dart';
import '../utilities/constants.dart';

class FriendListProvider extends ChangeNotifier {
  static const _pageSize = 10;

  final PagingController<int, Friendship> _pagingController =
      PagingController(firstPageKey: 0);
  final TextEditingController _searchController = TextEditingController();

  PagingController<int, Friendship> get pagingController => _pagingController;
  TextEditingController get searchController => _searchController;

  List<Friendship> _allFriends = [];
  String _searchQuery = '';

  void goToFriendProfile(
      BuildContext context, Friendship friendship, Bubble user) {
    GoRouter.of(context).push(
      Constants.profileAddress,
      extra: Profile(
        user: friendship.friend,
        currentUser: user,
        notifyParent: () {},
        friendship: friendship,
        isLocked: false,
      ),
    );
  }

  void initState({
    required Bubble mainUser,
  }) {
    try {
      // Preload initial friends into the PagingController.
      _allFriends = mainUser.friendships;
      _allFriends.sort((a, b) => b.strength().compareTo(a.strength()));
      if (_allFriends.isNotEmpty) {
        _pagingController.itemList = _allFriends;
      }

      _pagingController.addPageRequestListener((pageKey) {
        _fetchPage(pageKey, mainUser: mainUser);
      });
      _searchController.addListener(() {
        _filterFriends(_searchController.text);
      });
    } catch (e) {
      debugPrint('(FriendListProvider) Error in initState: $e');
    }
  }

  void disposeState() {
    _pagingController.dispose();
    _searchController.dispose();
  }

  void _filterFriends(String query) {
    _searchQuery = query.toLowerCase();
    List<Friendship> filteredFriends = _allFriends.where((friendship) {
      return friendship.friend.username.toLowerCase().contains(_searchQuery);
    }).toList();
    _pagingController.itemList = filteredFriends;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      notifyListeners();
    });
  }

  Future<void> _fetchPage(int pageKey, {required Bubble mainUser}) async {
    try {
      List<Friendship> friendships = [];

      if (mainUser.hasNonLoadedFriends()) {
        Iterable<dynamic> nonLoadedFriends = mainUser.nonLoadedFriends();

        debugPrint(
            '(FriendListProvider) Has non-loaded friendships: $nonLoadedFriends');

        nonLoadedFriends = nonLoadedFriends.take(30);

        final String id = mainUser.id;

        final QuerySnapshot querySnapshot =
            await Constants.friendshipsCollection
                .where(Filter.or(
                  Filter.and(
                      Filter(Constants.user1Doc, isEqualTo: id),
                      Filter(
                        Constants.user2Doc,
                        whereIn: nonLoadedFriends,
                      )),
                  Filter.and(
                      Filter(Constants.user2Doc, isEqualTo: id),
                      Filter(
                        Constants.user1Doc,
                        whereIn: nonLoadedFriends,
                      )),
                ))
                .orderBy(Constants.levelDoc, descending: true)
                .limit(_pageSize)
                .get();

        if (querySnapshot.docs.isNotEmpty) {
          for (QueryDocumentSnapshot snapshot in querySnapshot.docs) {
            String user1 = DataManager.getString(snapshot, Constants.user1Doc);
            String user2 = DataManager.getString(snapshot, Constants.user2Doc);
            String friendId;

            if (user1 == id) {
              friendId = user2;
            } else {
              friendId = user1;
            }

            final Friendship friendship =
                await DataQuery.getFriendship(id, friendId);

            debugPrint(
                '(FriendListProvider) Adding friend ${friendship.friend.username}');

            friendships.add(friendship);
            UserManager.addFriendToMain(friendship);
            UserManager.notify();
          }
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

      // Apply search filter to newly loaded data
      _filterFriends(_searchQuery);
    } catch (error) {
      _pagingController.error = error;
      debugPrint('(FriendListProvider) Error fetching page: $error');
    }
  }
}
