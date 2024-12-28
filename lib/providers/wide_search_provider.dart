import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../models/data/data_manager.dart';
import '../models/data/data_query.dart';
import '../models/data/user_manager.dart';
import '../models/objects/bubble.dart';
import '../models/objects/friendship.dart';
import '../models/objects/profile.dart';
import '../models/objects/search_history.dart';
import '../utilities/constants.dart';
import '../views/dialogs/wide/delete_history_dialog.dart';

class WideSearchProvider extends ChangeNotifier {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final PagingController<DocumentSnapshot?, Bubble> _pagingController =
      PagingController(firstPageKey: null);
  final PagingController<DocumentSnapshot?, SearchHistory>
      _historyPagingController = PagingController(firstPageKey: null);
  String _currentQuery = '';
  bool _showHistory = true;
  bool _hasUpdatedHistory = false;
  static const int _debounceTime = 400;

  bool isFocus = false;

  Timer? _debounce;

  FocusNode get focusNode => _focusNode;
  TextEditingController get searchController => _searchController;

  bool get showHistory => _showHistory;

  PagingController<DocumentSnapshot?, SearchHistory>
      get historyPagingController => _historyPagingController;
  PagingController<DocumentSnapshot?, Bubble> get pagingController =>
      _pagingController;
  bool hasFocus() {
    return _focusNode.hasFocus;
  }

  void initWidgetState() {
    _focusNode.addListener(() {
      notifyListeners();
    });
    _pagingController.addPageRequestListener((pageKey) {
      if (_currentQuery.isNotEmpty) {
        _fetchPage(pageKey);
      }
    });
    _historyPagingController.addPageRequestListener((pageKey) {
      _fetchSearchHistory(pageKey);
    });
  }

  Future<void> _fetchPage(DocumentSnapshot? lastDocument) async {
    try {
      Query query = Constants.usersCollection
          .where(Constants.usernameDoc, isGreaterThanOrEqualTo: _currentQuery)
          .where(Constants.usernameDoc,
              isLessThanOrEqualTo: '$_currentQuery\uf8ff')
          .orderBy(Constants.usernameDoc)
          .limit(10);

      if (_currentQuery == '0') {
        query = Constants.usersCollection
            .where(Constants.usernameDoc, isEqualTo: _currentQuery)
            .limit(10);
      }

      debugPrint("(WideSearchPage) Fetching Page");

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final QuerySnapshot snapshot = await query.get();
      final isLastPage = snapshot.docs.length < 10;

      final List<Bubble> bubbles = [];
      debugPrint("(WideSearchPage) Processing Documents");

      final Bubble mainUser = await UserManager.getInstance();

      for (DocumentSnapshot doc in snapshot.docs) {
        final ImageProvider avatar = await DataManager.getAvatar(doc);
        final Bubble bubble = Bubble.fromDocs(doc, avatar);
        if (!DataManager.isBlocked(bubble, mainUser)) {
          bubbles.add(bubble);
        }
      }

      if (isLastPage) {
        _pagingController.appendLastPage(bubbles);
      } else {
        _pagingController.appendPage(bubbles, snapshot.docs.last);
      }
    } catch (e) {
      debugPrint("(WideSearchPage) Error: $e");
      _pagingController.error = e;
    }
  }

  Future<void> _fetchSearchHistory(DocumentSnapshot? lastDocument) async {
    try {
      debugPrint('(WideSearchPage) Fetching history');
      final Bubble currentUser = await UserManager.getInstance();
      Query query = Constants.searchHistoryCollection
          .where('userId', isEqualTo: currentUser.id)
          .orderBy('timestamp', descending: true)
          .limit(10);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final QuerySnapshot snapshot = await query.get();
      final isLastPage = snapshot.docs.length < 10;

      debugPrint('(WideSearchPage) Querying history');

      final List<SearchHistory> history = [];

      final Bubble mainUser = await UserManager.getInstance();

      for (DocumentSnapshot doc in snapshot.docs) {
        final DateTime timestamp =
            DataManager.getDateTime(doc, Constants.timestampDoc);
        final String searchUserId =
            DataManager.getString(doc, Constants.searchedIdDoc);

        final DocumentSnapshot searchedDoc =
            await DataManager.getData(id: searchUserId);
        final ImageProvider avatar = await DataManager.getAvatar(searchedDoc);
        final Bubble bubble = Bubble.fromDocs(searchedDoc, avatar);

        if (!DataManager.isBlocked(bubble, mainUser)) {
          final SearchHistory search = SearchHistory(timestamp, bubble);

          history.add(search);
        }
      }

      if (isLastPage) {
        _historyPagingController.appendLastPage(history);
      } else {
        _historyPagingController.appendPage(history, snapshot.docs.last);
      }
    } catch (e) {
      debugPrint("(WideSearchPage) Error fetching history: $e");
      _historyPagingController.error = e;
    }
  }

  Future<void> onSearchChanged(String query) async {
    // Cancel any ongoing debounce timer
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    // Start a new debounce timer
    _debounce = Timer(const Duration(milliseconds: _debounceTime), () {
      _currentQuery = query.trim();
      _showHistory = _currentQuery.isEmpty;
      notifyListeners();

      if (_currentQuery.isEmpty) {
        _pagingController.itemList = [];
        if (_hasUpdatedHistory) {
          _historyPagingController.refresh();
          _hasUpdatedHistory = false;
        }
      } else {
        _pagingController.refresh();
      }
    });
  }

  Future<void> deleteHistoryEntry(SearchHistory history) async {
    try {
      final Bubble currentUser = await UserManager.getInstance();
      final QuerySnapshot querySnapshot = await Constants
          .searchHistoryCollection
          .where(Constants.userIdDoc, isEqualTo: currentUser.id)
          .where(Constants.searchedIdDoc, isEqualTo: history.bubble.id)
          .where(Constants.timestampDoc, isEqualTo: history.timestamp)
          .get();
      for (DocumentSnapshot doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
      _historyPagingController.itemList?.removeWhere((search) =>
          search.bubble.id == history.bubble.id &&
          search.timestamp == history.timestamp);
      notifyListeners();
      debugPrint(
          '(WideSearchPage) Deleted history entry for user ID: ${history.bubble.id}');
    } catch (e) {
      debugPrint('(WideSearchPage) Failed to delete history entry: $e');
    }
  }

  Future<void> goToFriendProfile(BuildContext context, Bubble user) async {
    final Bubble currentUser = await UserManager.getInstance();
    final bool isFriend = currentUser.friendIDs.contains(user.id);
    final Friendship friendship;
    if (isFriend) {
      friendship = await DataQuery.getFriendshipFromBubble(user);
    } else {
      friendship = Friendship.lockedFriendship(currentUser, user);
    }

    debugPrint('(WideSearchPage) Is Friend = $isFriend');
    if (context.mounted) {
      GoRouter.of(context).push(
        Constants.profileAddress,
        extra: Profile(
            user: user,
            currentUser: currentUser,
            notifyParent: () {},
            friendship: friendship,
            isLocked: !isFriend),
      );
    }
  }

  Future<void> _saveSearchHistory(String userId) async {
    try {
      final Bubble currentUser = await UserManager.getInstance();
      await Constants.searchHistoryCollection.add({
        Constants.userIdDoc: currentUser.id,
        Constants.searchedIdDoc: userId,
        Constants.timestampDoc: FieldValue.serverTimestamp(),
      });
      _hasUpdatedHistory = true;
      debugPrint('(WideSearchPage) Search history saved for user ID: $userId');
    } catch (e) {
      debugPrint('(WideSearchPage) Failed to save search history: $e');
    }
  }

  Future<void> _deleteHistory() async {
    try {
      final Bubble currentUser = await UserManager.getInstance();

      // Call a cloud function to delete the history
      final bool result = await _callDeleteUserSearchHistory(currentUser.id);

      if (result) {
        _historyPagingController.itemList?.clear();
        notifyListeners();
        debugPrint('(WideSearchPage) Deleted history');
      } else {
        _historyPagingController.refresh();
      }
    } catch (e) {
      debugPrint('(WideSearchPage) Failed to delete history: $e');
    }
  }

  /// Deletes the search history for a specific user by calling a Firebase Cloud Function.
  Future<bool> _callDeleteUserSearchHistory(String userId) async {
    try {
      // Create an instance of the Cloud Function
      final HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('deleteUserSearchHistory');

      // Call the Cloud Function with the userId
      final result = await callable.call({'userId': userId});

      // Handle the result
      return result.data['success'] == true;
    } catch (e) {
      // Handle any errors
      debugPrint('(WideSearchPage) Error calling deleteUserSearchHistory: $e');
      return false;
    }
  }

  void openEraseHistoryDialog(BuildContext context) {
    DeleteHistoryDialog.showDeleteHistoryDialog(context, _deleteHistory);
  }

  void disposeWidgetState() {
    _searchController.dispose();
    _pagingController.dispose();
    _historyPagingController.dispose();
    _focusNode.dispose();
    _debounce?.cancel(); // Clean up the debounce timer
  }

  void onTap(BuildContext context, Bubble user) {
    goToFriendProfile(context, user);
    _saveSearchHistory(user.id);
  }
}
