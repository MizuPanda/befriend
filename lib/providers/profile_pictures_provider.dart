import 'package:befriend/models/authentication/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../models/objects/picture.dart';
import '../utilities/constants.dart';

class ProfilePicturesProvider extends ChangeNotifier {
  static const _pageSize = 5;
  DocumentSnapshot? _lastVisible;
  int _nextAdIndex = -1;

  final PagingController<int, Picture> _pagingController =
      PagingController(firstPageKey: 0);

  PagingController<int, Picture> get pagingController => _pagingController;

  Function(int) _oldFetchPage = (_) {};

  bool _isReload = false;

  void _resetData() {
    _pagingController.removePageRequestListener(_oldFetchPage);
    _pagingController.itemList = []; // Clear the item list
    _pagingController.refresh();
    _lastVisible = null;
    _nextAdIndex = -1;
  }

  void initState(
      {required bool showArchived,
      required bool showOnlyMe,
      required String userID,
      required bool isWeb,
      required String? searchTerm}) {
    _resetData();

    _oldFetchPage = (pageKey) {
      _fetchPage(pageKey,
          userID: userID,
          showArchived: showArchived,
          showOnlyMe: showOnlyMe,
          isWeb: isWeb,
          searchTerm: searchTerm);
    };

    _pagingController.addPageRequestListener(_oldFetchPage);

    if (_isReload) {
      _pagingController.notifyPageRequestListeners(0);
    } else {
      _isReload = true;
    }
  }

  void disposeState() {
    _pagingController.dispose();
  }

  bool isConnectedUserProfile(String userID) {
    return userID == AuthenticationManager.id();
  }

  void handleArchiveSuccess(String archivedPictureId) {
    // Remove the archived picture from the _pagingController's item list
    final List<Picture> items =
        List<Picture>.from(_pagingController.itemList ?? []);
    items.removeWhere((item) => item.id == archivedPictureId);

    // Update the paging controller with the new item list
    _pagingController.itemList = items;
  }

  Future<void> _fetchPage(
    int pageKey, {
    required String userID,
    required bool showArchived,
    required bool showOnlyMe,
    required bool isWeb,
    required String? searchTerm,
  }) async {
    try {
      debugPrint(
          '(ProfilePicturesProvider) Fetching for userId=$userID, showArchived=$showArchived, showOnlyMe=$showOnlyMe, isWeb=$isWeb, searchTerm=$searchTerm');
      final Future<QuerySnapshot> query;
      Query q;

      String connectedID = AuthenticationManager.id();
      String notArchivedID = AuthenticationManager.notArchivedID();
      String archivedID = AuthenticationManager.archivedID();

      // Part 0: When you are in the web section
      // Part 1: When you are on your section of your profile
      // Part 2: When you are in your everyone's part of your profile
      // Part 3: When you are in your archives
      // Part 4: When you are on your friends profile (Filter after simple query)
      if (isWeb) {
        q = Constants.picturesCollection
            .where(Constants.publicDoc, isEqualTo: true);
        if (searchTerm != null && searchTerm.isNotEmpty) {
          q = q.where(Constants.pictureTakerDoc, isEqualTo: searchTerm);
        }
      } else if (showOnlyMe) {
        q = Constants.picturesCollection
            .where(Constants.hostId, isEqualTo: userID)
            .where(Constants.allowedUsersDoc, arrayContains: notArchivedID);
      } else if (userID == connectedID && !showArchived) {
        q = Constants.picturesCollection.where(Constants.allowedUsersDoc,
            arrayContainsAny: [notArchivedID, connectedID]);
      } else if (showArchived) {
        q = Constants.picturesCollection
            .where(Constants.allowedUsersDoc, arrayContains: archivedID);
      } else {
        q = Constants.picturesCollection.where(
          Constants.allowedUsersDoc,
          arrayContains: '${Constants.notArchived}$userID',
        );
      }

      q = q.orderBy(Constants.timestampDoc, descending: true);

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
      Iterable<Picture> pictures =
          querySnapshot.docs.map((doc) => Picture.fromDocument(doc)).toList();

      if (isWeb) {
        pictures = pictures.where((pic) => pic.allowedIDS.every((id) =>
            !id.toString().contains(Constants.archived) ||
            id.toString().contains(notArchivedID)));
      } else if (userID != connectedID) {
        pictures = pictures.where((pic) =>
            pic.allowedIDS.contains(connectedID) ||
            pic.allowedIDS.contains(archivedID) ||
            pic.allowedIDS.contains(notArchivedID));
      }

      if (_nextAdIndex == -1) {
        _nextAdIndex = 1;
        debugPrint('(ProfilePicturesProvider) Next ad at $_nextAdIndex');
      }

      for (int i = 0; i < pictures.length; i++) {
        newItems.add(pictures.elementAt(i));
        _nextAdIndex--;

        if (_nextAdIndex == 0) {
          newItems.add(Picture.pictureAd);
          _nextAdIndex = 3;
          debugPrint('(ProfilePicturesProvider) Next ad at $_nextAdIndex');
        }
      }

      final bool isLastPage = pictures.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final int nextPageKey = pageKey + pictures.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      debugPrint('(ProfilePicturesProvider) Error fetching page: $error');
      _pagingController.error = error;
    }
  }
}
