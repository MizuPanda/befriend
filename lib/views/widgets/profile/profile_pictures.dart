import 'package:befriend/models/data/user_manager.dart';
import 'package:befriend/models/objects/picture.dart';
import 'package:befriend/views/widgets/profile/custom_native_ad.dart';
import 'package:befriend/views/widgets/profile/picture_card.dart';
import 'package:befriend/providers/profile_pictures_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

import '../../../models/objects/bubble.dart';
import '../../../utilities/app_localizations.dart';
import '../shimmers/profile_pictures_shimmer.dart';

class ProfilePictures extends StatefulWidget {
  const ProfilePictures(
      {super.key,
      required this.profileUsername,
      required this.userID,
      required this.showArchived,
      required this.showOnlyMe,
      required this.isLocked});

  final String userID;
  final bool showArchived;
  final bool showOnlyMe;
  final bool isLocked;
  final String profileUsername;

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
        userID: widget.userID,
        isLocked: widget.isLocked);
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
                          provider.isConnectedUserProfile(widget.userID),
                      onArchiveSuccess: provider.handleArchiveSuccess,
                    );
                  }, noItemsFoundIndicatorBuilder: (BuildContext context) {
                    if (widget.isLocked) {
                      final double height = MediaQuery.of(context).size.height;
                      final double width = MediaQuery.of(context).size.width;

                      return Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.0 / 448 * width),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${AppLocalizations.translate(context, key: 'pp_need', defaultString: 'You need to add')} ${widget.profileUsername} ${AppLocalizations.translate(context, key: 'pp_friend', defaultString: 'as a friend to see their pictures.')}',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.openSans(
                                fontSize: 17,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            Text(
                              AppLocalizations.translate(context,
                                  key: 'pp_become',
                                  defaultString:
                                      'Take a picture with them to become friends'),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.openSans(
                                  fontSize: 15, color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            SizedBox(
                              height: 0.1 * height,
                            ),
                          ],
                        ),
                      );
                    }
                    return const Center();
                  }, firstPageProgressIndicatorBuilder: (BuildContext context) {
                    return const ProfilePicturesShimmer();
                  }),
                );
              });
            });
      });
}
