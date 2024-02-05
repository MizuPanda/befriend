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

  final PagingController<int, Picture> _pagingController = PagingController(firstPageKey: 0);

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      // Assuming `userId` is available for fetching the subcollection
      final String userId = widget.user.id;
      final QuerySnapshot querySnapshot = await Constants.usersCollection
          .doc(userId)
          .collection(Constants.pictureSubCollection)
          .orderBy(Constants.timestampDoc) // Ensure you have an index for this in Firestore
          .startAfter([pageKey])
          .limit(_pageSize)
          .get();

      final List<Picture> allPictures = querySnapshot.docs.map((doc) => Picture.fromDocument(doc)).toList();

      // Filter pictures based on the public field or if the user is in the allowed array
      final List<Picture> newItems = allPictures.where((picture) =>
      picture.public || picture.allowedIDS.contains(AuthenticationManager.id())).toList();

      final bool isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final int nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) =>
      PagedListView<int, Picture>(
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