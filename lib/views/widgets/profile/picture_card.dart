import 'package:auto_size_text/auto_size_text.dart';
import 'package:befriend/models/data/user_manager.dart';
import 'package:befriend/providers/profile_provider.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:like_button/like_button.dart';
import 'package:provider/provider.dart';

import '../../../models/objects/bubble.dart';
import '../../../models/objects/picture.dart';
import 'package:timeago/timeago.dart' as timeago;

class PictureCard extends StatefulWidget {
  final Picture picture;
  final String userID;
  final String connectedUsername;

  const PictureCard({
    Key? key,
    required this.picture,
    required this.userID,
    required this.connectedUsername,
  }) : super(key: key);

  @override
  State<PictureCard> createState() => _PictureCardState();
}

class _PictureCardState extends State<PictureCard> {
  final double _likeSize = 35;
  bool _isLiked = false;

  @override
  void initState() {
    _isLiked = widget.picture.likes.contains(widget.connectedUsername);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip
          .antiAlias, // Ensures the image is clipped to the card's boundaries
      child: Column(
        crossAxisAlignment: CrossAxisAlignment
            .stretch, // Makes the image stretch to fill the card width
        children: [
          Stack(
            children: [
              CachedNetworkImage(
                fit: BoxFit.scaleDown,
                imageUrl: widget.picture.fileUrl,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    SizedBox(
                        height: MediaQuery.of(context).size.width,
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                            child: CircularProgressIndicator(
                                value: downloadProgress.progress))),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
              Container(
                  alignment: Alignment.topRight,
                  padding: const EdgeInsets.only(right: 8, top: 10),
                  child: UserInfoIconButton(
                      usernames: widget.picture.sessionUsernames)),
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
                Row(
                  children: [
                    LikeButton(
                      mainAxisAlignment: MainAxisAlignment.start,
                      size: _likeSize,
                      isLiked: _isLiked,
                      onTap: (bool isLiked) async {
                        await Constants.usersCollection
                            .doc(widget.userID)
                            .collection(Constants.pictureSubCollection)
                            .doc(widget.picture.id)
                            .update({
                          Constants.likesDoc: isLiked
                              ? FieldValue.arrayRemove(
                                  [widget.connectedUsername])
                              : FieldValue.arrayUnion(
                                  [widget.connectedUsername]),
                        }).then((value) {
                          debugPrint(
                              '(PictureCard): Updated like to ${(!isLiked).toString()}');
                        }).onError((error, stackTrace) {
                          debugPrint(
                              '(PictureCard): Error updating likes= ${error.toString()}');
                        });

                        WidgetsBinding.instance
                            .addPostFrameCallback((timeStamp) {
                          setState(() {
                            if (isLiked) {
                              widget.picture.likes
                                  .remove(widget.connectedUsername);
                            } else {
                              widget.picture.likes
                                  .add(widget.connectedUsername);
                            }
                          });
                        });
                        _isLiked = !_isLiked;

                        return _isLiked;
                      },
                      circleColor: const CircleColor(
                          start: Color(0xff00ddff), end: Color(0xff0099cc)),
                      bubblesColor: const BubblesColor(
                        dotPrimaryColor: Color(0xff33b5e5),
                        dotSecondaryColor: Color(0xff0099cc),
                      ),
                      likeBuilder: (bool isLiked) {
                        return Icon(
                          !isLiked
                              ? Icons.favorite_border_rounded
                              : Icons.favorite_rounded,
                          color:
                              isLiked ? Colors.deepPurpleAccent : Colors.grey,
                          size: _likeSize,
                        );
                      },
                    ),
                    if (widget.picture.likes.isNotEmpty)
                      LikeText(
                        picture: widget.picture,
                        color: _isLiked ? Colors.deepPurpleAccent : Colors.grey,
                      )
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
                  style:
                      GoogleFonts.openSans(color: Colors.grey, fontSize: 12.5),
                ),
                const SizedBox(height: 2), // Adds a small space before the date
                Text(
                  _formatDate(widget.picture.timestamp),
                  style: GoogleFonts.openSans(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(
                  height: 5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    // This method converts the DateTime into a more readable string
    // Adjust the formatting to fit your needs
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}

class UserInfoIconButton extends StatelessWidget {
  final List<dynamic> usernames;

  const UserInfoIconButton({Key? key, required this.usernames})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 25,
      icon: Icon(
        Icons.info,
        color: Colors.grey.withOpacity(0.9),
      ), // Partially transparent icon
      onPressed: () => _showUsernamesDialog(context),
    );
  }

  Future<void> _showUsernamesDialog(BuildContext context) async {
    Bubble bubble = await UserManager.getInstance();

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text("People in this picture"),
            children: usernames
                .map((username) => SimpleDialogOption(
                      child:
                          Text(bubble.username == username ? 'You' : username),
                    ))
                .toList(),
          );
        },
      );
    }
  }
}

class LikeText extends StatelessWidget {
  const LikeText({super.key, required this.picture, required this.color});

  final Picture picture;
  final Color color;

  String getUser() {
    return '';
  }

  String usersThatLiked() {
    switch (picture.likes.length) {
      case 1:
        return picture.likes.first;
      default:
        return '${picture.likes.first} and others';
    }
  }

  Future<void> _showLikesDialog(BuildContext context) async {
    Bubble bubble = await UserManager.getInstance();

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_rounded,
                  color: Colors.red,
                ),
                Icon(
                  Icons.favorite_rounded,
                  color: Colors.red,
                ),
                Icon(
                  Icons.favorite_rounded,
                  color: Colors.red,
                )
              ],
            ),
            children: picture.likes
                .map((username) => SimpleDialogOption(
                      child:
                          Text(bubble.username == username ? 'You' : username),
                    ))
                .toList(),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(builder:
        (BuildContext context, ProfileProvider provider, Widget? child) {
      return TextButton(
          style: ButtonStyle(
            overlayColor: MaterialStateProperty.all(
                Colors.transparent), // Removes splash effect
          ),
          onPressed: () async {
            await _showLikesDialog(context);
          },
          child: AutoSizeText.rich(TextSpan(
              style: GoogleFonts.openSans(fontSize: 13, color: color),
              children: [
                const TextSpan(text: 'Liked by '),
                TextSpan(
                    text: usersThatLiked(),
                    style: const TextStyle(fontWeight: FontWeight.bold))
              ])));
    });
  }
}
