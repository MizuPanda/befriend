import 'package:auto_size_text/auto_size_text.dart';
import 'package:befriend/providers/picture_card_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:like_button/like_button.dart';
import 'package:provider/provider.dart';

import '../../../models/objects/picture.dart';
import 'package:timeago/timeago.dart' as timeago;

class PictureCard extends StatefulWidget {
  final Picture picture;
  final String userID;
  final String connectedUsername;
  final bool isConnectedUserProfile;
  final Function(String) onArchiveSuccess;

  const PictureCard({
    Key? key,
    required this.picture,
    required this.userID,
    required this.connectedUsername,
    required this.isConnectedUserProfile,
    required this.onArchiveSuccess,
  }) : super(key: key);

  @override
  State<PictureCard> createState() => _PictureCardState();
}

class _PictureCardState extends State<PictureCard> {
  late final PictureCardProvider _provider = PictureCardProvider(
      widget.picture,
      widget.userID,
      widget.connectedUsername,
      widget.isConnectedUserProfile,
      widget.onArchiveSuccess);
  final double _likeSize = 35;

  @override
  void initState() {
    _provider.initLikes();
    super.initState();
    debugPrint("(PictureCard): picture id = ${widget.picture.id}");
  }

  @override
  void didUpdateWidget(covariant PictureCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.picture.id != oldWidget.picture.id) {
      _provider.updatePicture(widget.picture);
      debugPrint("(PictureCard): Updated with: ${widget.picture.id}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: _provider,
        builder: (BuildContext context, Widget? child) {
          return Card(
            clipBehavior: Clip
                .antiAlias, // Ensures the image is clipped to the card's boundaries
            child: Consumer(builder: (BuildContext context,
                PictureCardProvider provider, Widget? child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment
                    .stretch, // Makes the image stretch to fill the card width
                children: [
                  Stack(
                    children: [
                      CachedNetworkImage(
                        fit: BoxFit.scaleDown,
                        imageUrl: widget.picture.fileUrl,
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) => SizedBox(
                                height: MediaQuery.of(context).size.width,
                                width: MediaQuery.of(context).size.width,
                                child: Center(
                                    child: CircularProgressIndicator(
                                        value: downloadProgress.progress))),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                      Container(
                          alignment: Alignment.topRight,
                          padding: const EdgeInsets.only(right: 8, top: 10),
                          child: MoreButton(
                            usernames: widget.picture.sessionUsers.values,
                          )),
                    ],
                  ), // Check if the image is fully loaded
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        if (!widget.picture.archived)
                          Row(
                            children: [
                              LikeButton(
                                mainAxisAlignment: MainAxisAlignment.start,
                                size: _likeSize,
                                isLiked: provider.isLiked,
                                onTap: provider.onLike,
                                circleColor: const CircleColor(
                                    start: Color(0xff00ddff),
                                    end: Color(0xff0099cc)),
                                bubblesColor: const BubblesColor(
                                  dotPrimaryColor: Color(0xff33b5e5),
                                  dotSecondaryColor: Color(0xff0099cc),
                                ),
                                likeBuilder: (bool isLiked) {
                                  return Icon(
                                    !isLiked
                                        ? Icons.favorite_border_rounded
                                        : Icons.favorite_rounded,
                                    color: isLiked
                                        ? Colors.deepPurpleAccent
                                        : Colors.grey,
                                    size: _likeSize,
                                  );
                                },
                              ),
                              if (widget.picture.likes.isNotEmpty)
                                const LikeText()
                            ],
                          ),
                        Text.rich(TextSpan(children: [
                          TextSpan(
                            text: widget.picture.pictureTaker,
                            style: GoogleFonts.openSans(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                              text: ' ${widget.picture.caption}',
                              style: GoogleFonts.openSans(fontSize: 14)),
                        ])),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          timeago.format(widget.picture.timestamp),
                          style: GoogleFonts.openSans(
                              color: Colors.grey, fontSize: 12.5),
                        ),
                        const SizedBox(
                            height: 2), // Adds a small space before the date
                        Text(
                          _formatDate(widget.picture.timestamp),
                          style: GoogleFonts.openSans(
                              color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          );
        });
  }

  String _formatDate(DateTime date) {
    // This method converts the DateTime into a more readable string
    // Adjust the formatting to fit your needs
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}

class MoreButton extends StatelessWidget {
  final Iterable<dynamic> usernames;

  const MoreButton({
    Key? key,
    required this.usernames,
  }) : super(key: key);

  static const double _iconTextDistance = 16;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder:
        (BuildContext context, PictureCardProvider provider, Widget? child) {
      return PopupMenuButton<PopSelection>(
        icon: Icon(
          Icons.more_vert,
          color: Colors.grey.withOpacity(0.9),
        ),
        itemBuilder: (BuildContext context) => [
          if (provider.isUsersProfile)
            PopupMenuItem<PopSelection>(
              value: PopSelection.archive,
              child: Row(
                children: [
                  const Icon(Icons.archive_outlined,
                      color: Colors.black), // Archive icon
                  const SizedBox(width: _iconTextDistance),
                  Text(provider.isArchived() ? 'Restore' : 'Archive'),
                  const SizedBox(width: _iconTextDistance * 2),
                ],
              ),
            ),
          if (provider.isPictureHost())
            const PopupMenuItem<PopSelection>(
              value: PopSelection.delete,
              child: Row(
                children: [
                  Icon(Icons.delete_outline_rounded,
                      color: Colors.red), // Archive icon
                  SizedBox(width: _iconTextDistance),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                  SizedBox(width: _iconTextDistance * 2),
                ],
              ),
            ),
          const PopupMenuItem<PopSelection>(
            value: PopSelection.info,
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    color: Colors.black), // Info icon
                SizedBox(width: _iconTextDistance),
                Text('Info'),
                SizedBox(width: _iconTextDistance * 2),
              ],
            ),
          ),
        ],
        onSelected: (PopSelection value) async {
          await provider.onSelectPop(value, context, usernames);
        },
      );
    });
  }
}

class LikeText extends StatelessWidget {
  const LikeText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PictureCardProvider>(builder:
        (BuildContext context, PictureCardProvider provider, Widget? child) {
      return TextButton(
          style: ButtonStyle(
            overlayColor: MaterialStateProperty.all(
                Colors.transparent), // Removes splash effect
          ),
          onPressed: () async {
            await provider.showLikesDialog(context);
          },
          child: AutoSizeText.rich(TextSpan(
              style:
                  GoogleFonts.openSans(fontSize: 13, color: provider.color()),
              children: [
                const TextSpan(text: 'Liked by '),
                TextSpan(
                    text: provider.usersThatLiked(),
                    style: const TextStyle(fontWeight: FontWeight.bold))
              ])));
    });
  }
}

enum PopSelection { archive, delete, info }
