import 'dart:async';

import 'package:befriend/models/data/data_query.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../models/data/data_manager.dart';
import '../models/objects/bubble.dart';
import '../models/objects/friendship.dart';
import '../models/objects/profile.dart';
import '../utilities/constants.dart';

class MutualProvider extends ChangeNotifier {
  final PagingController<int, Friendship> _pagingController =
      PagingController(firstPageKey: 0);

  PagingController<int, Friendship> get pagingController => _pagingController;

  final int _pageSize = 10;

  void initState(
      {required List<Friendship> loadedFriends,
      required List<dynamic> commonIDS,
      required Bubble mainUser}) {
    try {
      _pagingController.addPageRequestListener((pageKey) {
        _fetchPage(
          pageKey,
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
      {required List<dynamic> commonIDS}) async {
    try {
      final List<Friendship> newItems = [];

      debugPrint('(MutualProvider) Fetching page');

      // .where(username, isGreaterTo: searchQuery)
      //  .where(arrayContains: [])
      // Step 1: Get the next batch of user IDs from the list
      final List<dynamic> paginatedUserIds =
          commonIDS.skip(pageKey).take(_pageSize).toList();

      if (paginatedUserIds.isEmpty) {
        _pagingController.appendLastPage(newItems);

        return;
      }

      Query query = Constants.usersCollection
          .where(FieldPath.documentId, whereIn: paginatedUserIds)
          .orderBy(Constants.usernameDoc);

      final QuerySnapshot snapshot = await query.get();

      for (QueryDocumentSnapshot doc in snapshot.docs) {
        final ImageProvider avatar = await DataManager.getAvatar(doc);
        final Bubble friendBubble = Bubble.fromDocs(doc, avatar);

        final Friendship friendship =
            await DataQuery.getFriendshipFromBubble(friendBubble);

        newItems.add(friendship);
        debugPrint(
            '(FriendListProvider) Fetching friend ${friendship.friend.username}');
      }

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
