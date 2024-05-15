import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../models/authentication/authentication.dart';
import '../models/objects/picture.dart';
import '../utilities/constants.dart';

class ProfilePicturesProvider extends ChangeNotifier {
  static const _pageSize = 5;
  DocumentSnapshot? _lastVisible;
  int _nextAdIndex = 0;

  final PagingController<int, Picture> _pagingController =
      PagingController(firstPageKey: 0);

  PagingController<int, Picture> get pagingController => _pagingController;

  void initState({required String userId, required bool showArchived}) {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey, userId: userId, showArchived: showArchived);
    });
  }

  void disposeState() {
    _pagingController.dispose();
  }

  void handleArchiveSuccess(String archivedPictureId) {
    // Remove the archived picture from the _pagingController's item list
    final List<Picture> items =
        List<Picture>.from(_pagingController.itemList ?? []);
    items.removeWhere((item) => item.id == archivedPictureId);

    // Update the paging controller with the new item list
    _pagingController.itemList = items;
  }

  int _randomAdRange() {
    return 3 + Random().nextInt(3);
  }

  Future<void> _fetchPage(int pageKey,
      {required String userId, required bool showArchived}) async {
    try {
      final Future<QuerySnapshot> query;
      final Query q = Constants.usersCollection
          .doc(userId)
          .collection(Constants.pictureSubCollection)
          .where(Constants.archived, isEqualTo: showArchived)
          .where(Filter.or(
              Filter(Constants.publicDoc, isEqualTo: true),
              Filter(Constants.allowedUsersDoc,
                  arrayContains: AuthenticationManager.id())))
          .orderBy(Constants.timestampDoc, descending: true);

      if (pageKey == 0 || _lastVisible == null) {
        query = q.limit(_pageSize).get();
      } else {
        query = q.startAfterDocument(_lastVisible!).limit(_pageSize).get();
      }

      final QuerySnapshot querySnapshot = await query;

      if (querySnapshot.docs.isNotEmpty) {
        _lastVisible = querySnapshot.docs.last;
      }

      final List<Picture> newItems = [];
      final List<Picture> pictures =
          querySnapshot.docs.map((doc) => Picture.fromDocument(doc)).toList();

      if (_nextAdIndex == 0) {
        _nextAdIndex = _randomAdRange();
        debugPrint('(ProfilePicturesProvider): Next ad at $_nextAdIndex');
      }

      for (int i = 0; i < pictures.length; i++) {
        newItems.add(pictures[i]);
        if (_nextAdIndex - 1 == 0) {
          newItems.add(Picture.pictureAd);
          _nextAdIndex = _randomAdRange();
          debugPrint('(ProfilePicturesProvider): Next ad at $_nextAdIndex');
        }
        _nextAdIndex--;
      }

      final bool isLastPage = pictures.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final int nextPageKey = pageKey + pictures.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      debugPrint('(ProfilePicturesProvider): Error fetching page: $error');
      _pagingController.error = error;
    }
  }
}
