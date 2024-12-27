import 'package:befriend/models/authentication/authentication.dart';
import 'package:befriend/models/data/data_manager.dart';
import 'package:befriend/models/data/user_manager.dart';
import 'package:befriend/models/objects/bubble.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class LikesProvider extends ChangeNotifier {
  final PagingController<int, Bubble> _pagingController =
      PagingController(firstPageKey: 0);

  PagingController<int, Bubble> get pagingController => _pagingController;

  void initWidgetState(Iterable<dynamic> likes) {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey, likes);
    });
  }

  void disposeWidgetState() {
    _pagingController.dispose();
  }

  Future<void> _fetchPage(int pageKey, Iterable<dynamic> likes) async {
    try {
      const int pageSize =
          10; // Firestore's whereIn supports only 10 IDs per query

      // Step 1: Get the next batch of user IDs from the list
      final List<dynamic> paginatedUserIds =
          likes.skip(pageKey).take(pageSize).toList();

      if (paginatedUserIds.isEmpty) {
        _pagingController.appendLastPage([]);
        return;
      }

      final List<Bubble> newItems = [];

      if (paginatedUserIds.contains(AuthenticationManager.id())) {
        paginatedUserIds.remove(AuthenticationManager.id());

        final Bubble currentUser = await UserManager.getInstance();
        newItems.add(currentUser);
      }

      if (paginatedUserIds.isNotEmpty) {
        // Step 2: Fetch users from Firestore using the batch of IDs
        final QuerySnapshot snapshot = await Constants.usersCollection
            .where(FieldPath.documentId, whereIn: paginatedUserIds)
            .orderBy(Constants.usernameDoc)
            .get();

        // Step 3: Map documents to your Bubble model
        for (DocumentSnapshot doc in snapshot.docs) {
          final ImageProvider avatar = await DataManager.getAvatar(doc);
          final Bubble bubble = Bubble.fromDocs(doc, avatar);

          newItems.add(bubble);
        }
      }

      // Step 4: Check if this was the last page
      final bool isLastPage = paginatedUserIds.length < pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final int nextPageKey = pageKey + pageSize;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      debugPrint('(LikesProvider) Error fetching users: $error');
      _pagingController.error = error;
    }
  }
}
