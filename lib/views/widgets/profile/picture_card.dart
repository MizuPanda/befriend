import 'package:befriend/models/data/user_manager.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/objects/bubble.dart';
import '../../../models/objects/picture.dart';
import 'package:timeago/timeago.dart' as timeago;

class PictureCard extends StatefulWidget {
  final Picture picture;

  const PictureCard({Key? key, required this.picture}) : super(key: key);

  @override
  State<PictureCard> createState() => _PictureCardState();
}

class _PictureCardState extends State<PictureCard> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Card(
        clipBehavior: Clip
            .antiAlias, // Ensures the image is clipped to the card's boundaries
        child: Column(
          crossAxisAlignment: CrossAxisAlignment
              .stretch, // Makes the image stretch to fill the card width
          children: [
            Image(
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) {
                  return Stack(
                    children: [
                      child,
                      Container(
                          alignment: Alignment.topRight,
                          padding: const EdgeInsets.only(right: 8, top: 10),
                          child: UserInfoIconButton(
                              usernames: widget.picture.sessionUsernames)),
                    ],
                  ); // Check if the image is fully loaded
                }
                // Image is still loading
                return SizedBox(
                  width: double.infinity,
                  height: 400,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null, // If the total size is unknown, the progress indicator spins indeterminately.
                    ),
                  ),
                );
              },
              errorBuilder: (BuildContext context, Object exception,
                  StackTrace? stackTrace) {
                // Handle errors, for example, when the image can't be loaded
                return const Center(
                  child: Icon(Icons.error,
                      color: Colors
                          .red), // Display an error icon or any other widget
                );
              },
              image: widget.picture.image,
              fit: BoxFit.scaleDown, // Ensures the image covers the card area
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
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
                    style:
                        GoogleFonts.openSans(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                ],
              ),
            ),
          ],
        ),
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
