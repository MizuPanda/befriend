import 'dart:async';

import 'package:befriend/models/data/data_query.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../models/authentication/authentication.dart';
import '../models/data/data_manager.dart';
import '../models/objects/bubble.dart';
import '../models/objects/friendship.dart';
import '../models/objects/profile.dart';
import '../utilities/constants.dart';

class FriendListProvider extends ChangeNotifier {
  static const _pageSize = 8;
  static const int _debounceTime = 600;

  final PagingController<DocumentSnapshot?, Friendship> _pagingController =
      PagingController(firstPageKey: null);
  final TextEditingController _searchController = TextEditingController();

  PagingController<DocumentSnapshot?, Friendship> get pagingController =>
      _pagingController;
  TextEditingController get searchController => _searchController;

  Timer? _debounce;

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
      _pagingController.addPageRequestListener((pageKey) {
        _fetchPage(pageKey);
      });
    } catch (e) {
      debugPrint('(FriendListProvider) Error in initState: $e');
    }
  }

  void disposeState() {
    _pagingController.dispose();
    _searchController.dispose();
  }

  Future<void> onSearchChanged(String? query) async {
    if (query == null) {
      return;
    }
    // Cancel any ongoing debounce timer
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    // Start a new debounce timer
    _debounce = Timer(const Duration(milliseconds: _debounceTime), () {
      _searchQuery = query.trim();

      _pagingController.refresh();
    });
  }

  Future<void> _fetchPage(
    DocumentSnapshot? pageKey,
  ) async {
    try {
      final String currentUserId = AuthenticationManager.id();

      Query query = Constants.usersCollection
          .where(Constants.friendsDoc, arrayContains: currentUserId);

      if (_searchQuery.isNotEmpty && _searchQuery != '0') {
        query = query
            .where(Constants.usernameDoc, isGreaterThanOrEqualTo: _searchQuery)
            .where(Constants.usernameDoc,
                isLessThanOrEqualTo: '$_searchQuery\uf8ff')
            .orderBy(
                Constants.usernameDoc); // Order by the inequality field first
      }

      query =
          query.orderBy(Constants.powerDoc, descending: true).limit(_pageSize);

      if (pageKey != null) {
        query = query.startAfterDocument(pageKey);
      }

      final QuerySnapshot querySnapshot = await query.get();

      final List<Friendship> newItems = [];

      for (DocumentSnapshot doc in querySnapshot.docs) {
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
        _pagingController.appendPage(newItems, querySnapshot.docs.last);
      }
    } catch (error) {
      _pagingController.error = error;
      debugPrint('(FriendListProvider) Error fetching page: $error');
    }
  }
}
