import 'package:befriend/models/data/data_manager.dart';
import 'package:befriend/models/data/user_manager.dart';
import 'package:befriend/models/objects/bubble.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../models/data/data_query.dart';
import '../utilities/app_localizations.dart';
import '../utilities/error_handling.dart';
import '../views/dialogs/settings/unblock_dialog.dart';

class BlockedSettingsProvider extends ChangeNotifier {
  final PagingController<int, Bubble> _pagingController =
      PagingController(firstPageKey: 0);

  PagingController<int, Bubble> get pagingController => _pagingController;

  void initWidgetState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  void disposeWidgetState() {
    _pagingController.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      const int pageSize =
          10; // Firestore's whereIn supports only 10 IDs per query

      final Bubble currentUser = await UserManager.getInstance();

      // Step 1: Get the next batch of user IDs from the list
      final List<dynamic> paginatedUserIds =
          currentUser.blockedUsers.skip(pageKey).take(pageSize).toList();

      if (paginatedUserIds.isEmpty) {
        _pagingController.appendLastPage([]);

        debugPrint('');
        return;
      }

      // Step 2: Fetch users from Firestore using the batch of IDs
      final QuerySnapshot snapshot = await Constants.usersCollection
          .where(FieldPath.documentId, whereIn: paginatedUserIds)
          .orderBy(Constants.usernameDoc)
          .get();

      final List<Bubble> newItems = [];

      // Step 3: Map documents to your Bubble model
      for (DocumentSnapshot doc in snapshot.docs) {
        final ImageProvider avatar = await DataManager.getAvatar(doc);
        final Bubble bubble = Bubble.fromDocs(doc, avatar);

        newItems.add(bubble);
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
      debugPrint('(BlockedSettingsProvider) Error fetching users: $error');
      _pagingController.error = error;
    }
  }

  Future<void> unblockUser(Bubble bubble, BuildContext context) async {
    UnblockDialog.showUnblockDialog(
      context,
      bubble.username,
      () async {
        try {
          debugPrint('(BlockedSettingsProvider) Unblock my man ${bubble.id}');
          await DataQuery.updateDocument(
              Constants.blockedUsersDoc, FieldValue.arrayRemove([bubble.id]));

          UserManager.removeBlockedUser(bubble.id);
          _pagingController.itemList?.remove(bubble);
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            notifyListeners();
          });
        } catch (e) {
          debugPrint('(BlockedSettingsProvider) Error: $e');
          if (context.mounted) {
            ErrorHandling.showError(
                context,
                AppLocalizations.of(context)
                        ?.translate('general_error_message7') ??
                    'An unexpected error occurred. Please try again.');
          }
        }
      },
    );
  }
}
