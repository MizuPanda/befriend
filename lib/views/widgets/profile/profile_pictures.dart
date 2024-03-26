import 'dart:math';

import 'package:befriend/models/authentication/authentication.dart';
import 'package:befriend/models/data/user_manager.dart';
import 'package:befriend/models/objects/picture.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:befriend/views/widgets/profile/custom_native_ad.dart';
import 'package:befriend/views/widgets/profile/picture_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../models/objects/bubble.dart';

class ProfilePictures extends StatefulWidget {
  const ProfilePictures({
    super.key,
    required this.userID,
    required this.showArchived,
  });

  final String userID;
  final bool showArchived;

  @override
  State<ProfilePictures> createState() => _ProfilePicturesState();
}

class _ProfilePicturesState extends State<ProfilePictures> {
  static const _pageSize = 5;
  DocumentSnapshot? _lastVisible;
  int _nextAdIndex = 0;

  final PagingController<int, Picture> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  int _randomAdRange() {
    return 4 + Random().nextInt(3);
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final String userId = widget.userID;
      final Future<QuerySnapshot> query;
      final Query q = Constants.usersCollection
          .doc(userId)
          .collection(Constants.pictureSubCollection)
          .where(Constants.archived, isEqualTo: widget.showArchived)
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

      query.then(
        (value) {
          int index = value.size - 1;
          if (index >= 0) {
            _lastVisible = value.docs[value.size - 1];
          }
        },
        onError: (e) => debugPrint("(ProfilePictures): Error completing: $e"),
      );

      final QuerySnapshot querySnapshot = await query;

      final List<Picture> newItems = [];

      final List<Picture> pictures =
          querySnapshot.docs.map((doc) => Picture.fromDocument(doc)).toList();

      if (_nextAdIndex == 0) {
        _nextAdIndex = _randomAdRange(); // Randomly choose between 4, 5, or 6
        debugPrint('(ProfilePictures): Next ad at $_nextAdIndex');
      }

      for (int i = 0; i < pictures.length; i++) {
        newItems.add(pictures[i]);
        if (_nextAdIndex - 1 == 0) {
          newItems.add(Picture.pictureAd); // Placeholder for an ad
          _nextAdIndex = _randomAdRange(); // Set next ad position
          debugPrint('(ProfilePictures): Next ad at $_nextAdIndex');
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
      debugPrint('(ProfilePictures): Error= $error');
      _pagingController.error = error;
    }
  }

  void _handleArchiveSuccess(String archivedPictureId) {
    // Remove the archived picture from the _pagingController's item list
    final List<Picture> items =
        List<Picture>.from(_pagingController.itemList ?? []);
    items.removeWhere((item) => item.id == archivedPictureId);

    // Update the paging controller with the new item list
    _pagingController.itemList = items;
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Bubble>(
      future: UserManager.getInstance(),
      builder: (BuildContext context, AsyncSnapshot<Bubble> mainBubble) {
        if (!mainBubble.hasData || mainBubble.data == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return PagedListView<int, Picture>(
          pagingController: _pagingController,
          cacheExtent: 3600,
          builderDelegate: PagedChildBuilderDelegate<Picture>(
              itemBuilder: (context, item, index) {
            if (item == Picture.pictureAd) {
              return const CustomNativeAd();
            }

            return PictureCard(
              picture: item,
              userID: widget.userID,
              connectedUsername: mainBubble.data!.username,
              isConnectedUserProfile:
                  widget.userID == AuthenticationManager.id(),
              onArchiveSuccess: _handleArchiveSuccess,
            );
          }, noItemsFoundIndicatorBuilder: (BuildContext context) {
            return const Center();
          }),
        );
      });

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
