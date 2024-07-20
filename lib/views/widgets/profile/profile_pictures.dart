import 'package:befriend/models/data/user_manager.dart';
import 'package:befriend/models/objects/picture.dart';
import 'package:befriend/utilities/models.dart';
import 'package:befriend/views/widgets/profile/custom_native_ad.dart';
import 'package:befriend/views/widgets/profile/picture_card.dart';
import 'package:befriend/providers/profile_pictures_provider.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

import '../../../models/objects/bubble.dart';
import '../shimmers/profile_pictures_shimmer.dart';

class ProfilePictures extends StatefulWidget {
  const ProfilePictures({
    super.key,
    required this.userID,
    required this.showArchived,
    required this.showOnlyMe,
  });

  final String userID;
  final bool showArchived;
  final bool showOnlyMe;

  @override
  State<ProfilePictures> createState() => _ProfilePicturesState();
}

class _ProfilePicturesState extends State<ProfilePictures> {
  final ProfilePicturesProvider _provider = ProfilePicturesProvider();

  @override
  void initState() {
    super.initState();
    _provider.initState(
        showArchived: widget.showArchived,
        showOnlyMe: widget.showOnlyMe,
        userID: widget.userID);
  }

  @override
  void dispose() {
    _provider.disposeState();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Bubble>(
      future: UserManager.getInstance(),
      builder: (BuildContext context, AsyncSnapshot<Bubble> mainBubble) {
        if (!mainBubble.hasData || mainBubble.data == null) {
          return const ProfilePicturesShimmer();
        }

        return ChangeNotifierProvider.value(
            value: _provider,
            builder: (BuildContext context, Widget? child) {
              return Consumer<ProfilePicturesProvider>(builder:
                  (BuildContext context, ProfilePicturesProvider provider,
                      Widget? child) {
                return PagedListView<int, Picture>(
                  pagingController: provider.pagingController,
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
                          widget.userID == Models.authenticationManager.id(),
                      onArchiveSuccess: provider.handleArchiveSuccess,
                    );
                  }, noItemsFoundIndicatorBuilder: (BuildContext context) {
                    return const Center();
                  }, firstPageProgressIndicatorBuilder: (BuildContext context) {
                    return const ProfilePicturesShimmer();
                  }),
                );
              });
            });
      });
}
