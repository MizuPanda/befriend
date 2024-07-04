import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../models/data/data_manager.dart';
import '../models/objects/bubble.dart';
import '../models/objects/friendship.dart';
import '../utilities/constants.dart';
import '../utilities/models.dart';

class MutualProvider extends ChangeNotifier {
  List<Bubble> _filteredUsers = [];
  List<Bubble> _allLoadedUsers = [];

  DocumentSnapshot? _lastDocument;

  final PagingController<int, Bubble> _pagingController =
      PagingController(firstPageKey: 0);

  PagingController<int, Bubble> get pagingController => _pagingController;

  final int _pageSize = 10;

  bool _isSearching = false;

  bool get isSearching => _isSearching;

  int length() {
    return _filteredUsers.length;
  }

  Bubble user(int index) {
    return _filteredUsers[index];
  }

  void initState(
      {required List<Bubble> commonFriends,
      required String userId,
      required bool hasNonLoadedFriends,
      required Future<DocumentSnapshot> getLastFriendshipDocument}) {
    try {
      _pagingController.itemList = commonFriends;
      _allLoadedUsers = commonFriends;

      _pagingController.addPageRequestListener((pageKey) {
        _fetchPage(pageKey,
            hasNonLoadedFriends: hasNonLoadedFriends,
            getLastFriendshipDocument: getLastFriendshipDocument,
            userId: userId);
        _allLoadedUsers = _pagingController.itemList!;
      });
    } catch (e) {
      debugPrint('(MutualProvider) Error in initState: $e');
    }
  }

  Future<void> _fetchPage(int pageKey,
      {required String userId,
      required bool hasNonLoadedFriends,
      required Future<DocumentSnapshot> getLastFriendshipDocument}) async {
    try {
      final List<Friendship> moreFriends = [];

      if (hasNonLoadedFriends) {
        if (_lastDocument == null || pageKey == 0) {
          _lastDocument ??= await getLastFriendshipDocument;
        }

        // Your Firestore query to fetch more friends, starting after the last document
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
                await Models.dataManager.getData(id: friendId);
            ImageProvider bubbleImage =
                await Models.dataManager.getAvatar(bubbleSnapshot);

            friend = Bubble.fromDocsWithoutFriends(bubbleSnapshot, bubbleImage);

            Friendship friendship =
                Friendship.fromDocs(userId, friend, snapshot);
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
    } catch (error) {
      _pagingController.error = error;
      debugPrint('(MutualProvider) Error fetching page: $error');
    }
  }

  void filterUsers(String searchTerm) {
    final lowerCaseSearchTerm = searchTerm.toLowerCase();

    _filteredUsers = _allLoadedUsers.where((user) {
      return user.username.toLowerCase().contains(lowerCaseSearchTerm);
    }).toList();

    _isSearching = searchTerm.isNotEmpty;
    notifyListeners();
  }
}
