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

  PagingController<int, Friendship> get pagingController => _pagingController;

  DocumentSnapshot? _lastDocument;

  void goToFriendProfile(
      BuildContext context, Friendship friendship, Bubble user) {
    GoRouter.of(context).push(
      Constants.profileAddress,
      extra: Profile(
          user: friendship.friend,
          currentUser: user,
          notifyParent: () {},
          friendship: friendship),
    );
  }

  void initState(List<Friendship> friendships,
      {required bool hasNonLoadedFriends,
      required Future<DocumentSnapshot> lastFriendshipDocument,
      required String id}) {
    try {
      // Preload initial friends into the PagingController.
      final List<Friendship> initialFriends = friendships;
      if (initialFriends.isNotEmpty) {
        _pagingController.itemList = initialFriends;
      }

      _pagingController.addPageRequestListener((pageKey) {
        _fetchPage(pageKey,
            hasNonLoadedFriends: hasNonLoadedFriends,
            lastFriendshipDocument: lastFriendshipDocument,
            id: id);
      });
    } catch (e) {
      debugPrint('(FriendListProvider): Error in initState: $e');
    }
  }

  void disposeState() {
    _pagingController.dispose();
  }

  Future<void> _fetchPage(int pageKey,
      {required bool hasNonLoadedFriends,
      required Future<DocumentSnapshot> lastFriendshipDocument,
      required String id}) async {
    try {
      List<Friendship> friendships = [];

      if (hasNonLoadedFriends) {
        debugPrint('(FriendListProvider): Has non-loaded friendships');

        if (pageKey == 0 || _lastDocument == null) {
          _lastDocument ??= await lastFriendshipDocument;
        }

        QuerySnapshot querySnapshot = await Constants.friendshipsCollection
            .where(Filter.or(
              Filter(
                Constants.user1Doc,
                isEqualTo: id,
              ),
              Filter(
                Constants.user2Doc,
                isEqualTo: id,
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

          if (user1 == id) {
            friendId = user2;
          } else {
            friendId = user1;
          }

          DocumentSnapshot bubbleSnapshot =
              await DataManager.getData(id: friendId);
          ImageProvider bubbleImage =
              await DataManager.getAvatar(bubbleSnapshot);

          friend = Bubble.fromDocsWithoutFriends(bubbleSnapshot, bubbleImage);

          Friendship friendship = Friendship.fromDocs(id, friend, snapshot);
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
      debugPrint('(FriendListProvider): Error fetching page: $error');
    }
  }
}
