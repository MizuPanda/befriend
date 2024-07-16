import 'package:auto_size_text/auto_size_text.dart';
import 'package:befriend/providers/picture_card_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';
import 'package:provider/provider.dart';

import '../../../models/objects/picture.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'like_text.dart';
import 'more_button.dart';

class PictureCard extends StatefulWidget {
  final Picture picture;
  final String userID;
  final String connectedUsername;
  final bool isConnectedUserProfile;
  final Function(String) onArchiveSuccess;

  const PictureCard({
    super.key,
    required this.picture,
    required this.userID,
    required this.connectedUsername,
    required this.isConnectedUserProfile,
    required this.onArchiveSuccess,
  });

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
  final double _likeSizeWidthMultiplier = 35 / 448;

  @override
  void initState() {
    _provider.initLikes();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant PictureCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.picture.id != oldWidget.picture.id) {
      _provider.updatePicture(widget.picture);
      debugPrint("(PictureCard) Updated with: ${widget.picture.id}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

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
                                height: width,
                                width: width,
                                child: Center(
                                    child: CircularProgressIndicator(
                                        value: downloadProgress.progress))),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                      Container(
                          alignment: Alignment.topRight,
                          padding: EdgeInsets.only(
                              right: 8 / 448 * width, top: 0.01 * height),
                          child: MoreButton(
                            usernames: widget.picture.sessionUsers.values,
                          )),
                    ],
                  ), // Check if the image is fully loaded
                  Padding(
                    padding: EdgeInsets.only(left: 16.0 / 448 * width),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 0.01 * height,
                        ),
                        if (!widget.picture.hasUserArchived())
                          Row(
                            children: [
                              LikeButton(
                                mainAxisAlignment: MainAxisAlignment.start,
                                size: _likeSizeWidthMultiplier * width,
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
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey,
                                    size: _likeSizeWidthMultiplier * width,
                                  );
                                },
                              ),
                              if (widget.picture.likes.isNotEmpty)
                                const LikeText()
                            ],
                          ),
                        AutoSizeText.rich(TextSpan(children: [
                          TextSpan(
                            text: widget.picture.pictureTaker,
                            style: GoogleFonts.openSans(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                              text: ' ${widget.picture.caption}',
                              style: GoogleFonts.openSans(fontSize: 14)),
                        ])),
                        SizedBox(
                          height: 0.004 * height,
                        ),
                        AutoSizeText(
                          timeago.format(widget.picture.timestamp),
                          style: GoogleFonts.openSans(
                              color: Colors.grey, fontSize: 12.5),
                        ),
                        SizedBox(
                            height: 0.002 *
                                height), // Adds a small space before the date
                        AutoSizeText(
                          _formatDate(widget.picture.timestamp),
                          style: GoogleFonts.openSans(
                              color: Colors.grey, fontSize: 12),
                        ),
                        SizedBox(
                          height: 0.005 * height,
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
    // Get the current locale
    Locale currentLocale = Localizations.localeOf(context);

    // Create a DateFormat instance with the current locale
    DateFormat dateFormat = DateFormat.yMd(currentLocale.toString());

    return dateFormat.format(date);
  }
}
