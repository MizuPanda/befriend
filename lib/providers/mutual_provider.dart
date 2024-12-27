import 'package:befriend/models/data/data_query.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../models/data/data_manager.dart';
import '../models/data/user_manager.dart';
import '../models/objects/bubble.dart';
import '../models/objects/friendship.dart';
import '../models/objects/profile.dart';
import '../utilities/constants.dart';

class MutualProvider extends ChangeNotifier {
  List<Friendship> _filteredUsers = [];
  List<Friendship> _allLoadedUsers = [];

  final PagingController<int, Friendship> _pagingController =
      PagingController(firstPageKey: 0);

  PagingController<int, Friendship> get pagingController => _pagingController;

  final int _pageSize = 10;

  bool _isSearching = false;

  bool get isSearching => _isSearching;

  int length() {
    return _filteredUsers.length;
  }

  Friendship friendshipAt(int index) {
    return _filteredUsers[index];
  }

  void initState(
      {required List<Friendship> loadedFriends,
      required List<dynamic> commonIDS,
      required Bubble mainUser}) {
    try {
      _allLoadedUsers = loadedFriends;
      if (_allLoadedUsers.isNotEmpty) {
        _pagingController.itemList = _allLoadedUsers;
      }

      _pagingController.addPageRequestListener((pageKey) {
        _fetchPage(
          pageKey,
          mainUser: mainUser,
          commonIDS: commonIDS,
        );
      });
    } catch (e) {
      debugPrint('(MutualProvider) Error in initState: $e');
    }
  }

  void disposeState() {
    _pagingController.dispose();
  }

  Future<void> _fetchPage(int pageKey,
      {required Bubble mainUser, required List<dynamic> commonIDS}) async {
    try {
      final List<Friendship> friendships = [];
      final String userId = mainUser.id;

      final bool hasNonLoadedCommons =
          _allLoadedUsers.length != commonIDS.length;
      debugPrint('(MutualProvider) Fetching page');

      if (hasNonLoadedCommons) {
        Iterable<dynamic> nonLoadedMutual = commonIDS.where((id) =>
            !_allLoadedUsers
                .map((friendship) => friendship.friend.id)
                .contains(id));

        debugPrint('(MutualProvider) Has non-loaded mutual: $nonLoadedMutual');

        nonLoadedMutual = nonLoadedMutual.take(30);

        debugPrint('(MutualProvider) Top 30: $nonLoadedMutual');

        // Your Firestore query to fetch more friends, starting after the last document
        final QuerySnapshot querySnapshot =
            await Constants.friendshipsCollection
                .where(Filter.or(
                  Filter.and(
                      Filter(Constants.user1Doc, isEqualTo: userId),
                      Filter(
                        Constants.user2Doc,
                        whereIn: nonLoadedMutual,
                      )),
                  Filter.and(
                      Filter(Constants.user2Doc, isEqualTo: userId),
                      Filter(
                        Constants.user1Doc,
                        whereIn: nonLoadedMutual,
                      )),
                ))
                .orderBy(Constants.levelDoc, descending: true)
                .limit(_pageSize)
                .get();

        debugPrint('(MutualProvider) ${querySnapshot.size} new mutual');

        if (querySnapshot.docs.isNotEmpty) {
          for (QueryDocumentSnapshot snapshot in querySnapshot.docs) {
            String user1 = DataManager.getString(snapshot, Constants.user1Doc);
            String user2 = DataManager.getString(snapshot, Constants.user2Doc);
            String friendId;

            if (user1 == userId) {
              friendId = user2;
            } else {
              friendId = user1;
            }

            final Friendship friendship =
                await DataQuery.getFriendship(userId, friendId);

            debugPrint(
                '(MutualProvider) Adding mutual ${friendship.friend.username}');

            friendships.add(friendship);
            UserManager.addFriendToMain(friendship);
            UserManager.notify();
            _allLoadedUsers.add(friendship);
          }
        }
      }

      final isLastPage = friendships.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(friendships);
      } else {
        final int nextPageKey = pageKey + friendships.length;
        _pagingController.appendPage(friendships, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
      debugPrint('(MutualProvider) Error fetching page: $error');
    }
  }

  void filterUsers(String searchTerm) {
    final lowerCaseSearchTerm = searchTerm.toLowerCase();

    _filteredUsers = _allLoadedUsers.where((friendship) {
      return friendship.friend.username
          .toLowerCase()
          .contains(lowerCaseSearchTerm);
    }).toList();

    _isSearching = searchTerm.isNotEmpty;
    notifyListeners();
  }

  void goToFriendProfile(
      BuildContext context, int index, Friendship friendship, Bubble mainUser) {
    GoRouter.of(context).push(
      Constants.profileAddress,
      extra: Profile(
          user: friendship.friend,
          currentUser: mainUser,
          notifyParent: () {},
          friendship: friendship,
          isLocked: false),
    );
  }
}
