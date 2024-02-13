import 'package:befriend/models/authentication/authentication.dart';
import 'package:befriend/models/objects/picture.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:befriend/views/widgets/profile/picture_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../models/objects/bubble.dart';

class ProfilePictures extends StatefulWidget {
  const ProfilePictures({
    super.key,
    required this.user,
  });

  final Bubble user;

  @override
  State<ProfilePictures> createState() => _ProfilePicturesState();
}

class _ProfilePicturesState extends State<ProfilePictures> {
  static const _pageSize = 5;
  DocumentSnapshot? _lastVisible;

  final PagingController<int, Picture> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final String userId = widget.user.id;
      final Future<QuerySnapshot> query;
      if (pageKey == 0 && _lastVisible == null) {
        query = Constants.usersCollection
            .doc(userId)
            .collection(Constants.pictureSubCollection)
            .where(Filter.or(
                Filter(Constants.publicDoc, isEqualTo: true),
                Filter(Constants.allowedUsersDoc,
                    arrayContains: AuthenticationManager.id())))
            .orderBy(Constants.timestampDoc, descending: true)
            .limit(_pageSize)
            .get();
      } else {
        query = Constants.usersCollection
            .doc(userId)
            .collection(Constants.pictureSubCollection)
            .where(Filter.or(
                Filter(Constants.publicDoc, isEqualTo: true),
                Filter(Constants.allowedUsersDoc,
                    arrayContains: AuthenticationManager.id())))
            .orderBy(Constants.timestampDoc, descending: true)
            .startAfterDocument(_lastVisible!)
            .limit(_pageSize)
            .get();
      }

      query.then(
        (value) {
          int index = value.size - 1;
          if (index >= 0) {
            _lastVisible = value.docs[value.size - 1];
          }
        },
        onError: (e) => debugPrint("(Pictures): Error completing: $e"),
      );

      final QuerySnapshot querySnapshot = await query;

      final List<Picture> newItems =
          querySnapshot.docs.map((doc) => Picture.fromDocument(doc)).toList();

      final bool isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final int nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      debugPrint(error.toString());
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) => PagedListView<int, Picture>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<Picture>(
          itemBuilder: (context, item, index) => PictureCard(
            picture: item,
          ),
        ),
      );

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
