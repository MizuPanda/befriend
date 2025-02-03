import 'package:befriend/models/authentication/authentication.dart';
import 'package:befriend/models/data/data_manager.dart';
import 'package:befriend/models/data/data_query.dart';
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
      required bool isLocked}) {
    _resetData();

    _oldFetchPage = (pageKey) {
      _fetchPage(pageKey,
          userID: userID,
          showArchived: showArchived,
          showOnlyMe: showOnlyMe,
          isLocked: isLocked);
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

  Future<void> _fetchPage(int pageKey,
      {required String userID,
      required bool showArchived,
      required bool showOnlyMe,
      required bool isLocked}) async {
    try {
      debugPrint(
          '(ProfilePicturesProvider) Fetching for userId=$userID, showArchived=$showArchived, showOnlyMe=$showOnlyMe, isLocked=$isLocked');
      final Future<QuerySnapshot> query;
      Query q;

      final String connectedID = AuthenticationManager.id();
      final String notArchivedID = AuthenticationManager.notArchivedID();
      final String archivedID = AuthenticationManager.archivedID();

      // Part 1: When you are on your section of your profile
      // Part 2: When you are in your everyone's part of your profile
      // Part 3: When you are in your archives
      // Part 4: When you are on your friends profile (Filter after simple query)
      // Part 5: When you are on a non-friend profile
      if (showOnlyMe) {
        q = Constants.picturesCollection
            .where(Constants.hostIdDoc, isEqualTo: userID)
            .where(Constants.allowedUsersDoc, arrayContains: notArchivedID);
      } else if (userID == connectedID && !showArchived) {
        q = Constants.picturesCollection.where(Constants.allowedUsersDoc,
            arrayContainsAny: [notArchivedID, connectedID]);
      } else if (showArchived) {
        q = Constants.picturesCollection
            .where(Constants.allowedUsersDoc, arrayContains: archivedID);
      } else if (!isLocked) {
        q = Constants.picturesCollection.where(
          Constants.allowedUsersDoc,
          arrayContains: '${Constants.notArchived}$userID',
        );
      } else {
        q = Constants.picturesCollection
            .where(Constants.allowedUsersDoc,
                arrayContains: '${Constants.notArchived}$userID')
            .where(Constants.publicDoc, isEqualTo: true);
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
      List<Picture> pictures = [];

      for (DocumentSnapshot snapshot in querySnapshot.docs) {
        final String hostId =
            DataManager.getString(snapshot, Constants.hostIdDoc);
        final String hostUsername = await DataQuery.getUsername(hostId);
        final Picture picture = Picture.fromDocument(snapshot, hostUsername);
        pictures.add(picture);
      }

      // Filtering part to filter pictures you are allowed to see
      if (userID != connectedID && !isLocked) {
        pictures = pictures
            .where((pic) =>
                pic.allowedIDS.contains(connectedID) ||
                pic.allowedIDS.contains(archivedID) ||
                pic.allowedIDS.contains(notArchivedID) ||
                pic.isPublic)
            .toList();
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
