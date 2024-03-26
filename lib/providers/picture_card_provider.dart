import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import '../models/data/user_manager.dart';
import '../models/objects/bubble.dart';
import '../models/objects/picture.dart';
import '../models/services/post_service.dart';
import '../utilities/constants.dart';
import '../views/widgets/profile/picture_card.dart';

class PictureCardProvider extends ChangeNotifier {
  Picture _picture;
  final String _connectedUsername;

  /// Defines the value of profile.user.id
  final String _userId;
  final bool _isUsersProfile;

  final Function(String) _onPictureActionSuccess; // Add this line

  Color color() {
    return _isLiked ? Colors.deepPurpleAccent : Colors.black;
  }

  PictureCardProvider(this._picture, this._userId, this._connectedUsername,
      this._isUsersProfile, this._onPictureActionSuccess);

  bool _isLiked = false;
  late bool _isNotLikedYet;

  bool get isLiked => _isLiked;
  bool get isUsersProfile => _isUsersProfile;

  void initLikes() {
    _isLiked = _picture.likes.contains(_connectedUsername);
    _isNotLikedYet = !_picture.firstLikes.contains(_connectedUsername);
  }

  void updatePicture(Picture picture) {
    _picture = picture;
  }

  /// isPictureHost() returns true if the picture was taken
  ///   by the user of the current profile.
  bool isPictureHost() {
    return _picture.hostId == _userId;
  }

  bool isArchived() {
    return _picture.archived;
  }

  Future<void> onSelectPop(PopSelection value, BuildContext context,
      Iterable<dynamic> usernames) async {
    switch (value) {
      case PopSelection.archive:
        // Handle archive action
        if (isArchived()) {
          await _restorePicture();
        } else {
          await _archivePicture();
        }
        debugPrint('(PictureCardProvider): Archive action tapped');
        break;
      case PopSelection.info:
        // Handle info action (show usernames dialog)
        _showUsernamesDialog(context, usernames);
        break;
      case PopSelection.delete:
        await _deletePicture(context);
        break;
    }
  }

  Future<void> _deletePicture(BuildContext context) async {
    const double textButtonSize = 15.0;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete this picture',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text.rich(TextSpan(children: [
            TextSpan(
                text:
                    "Are you sure you want to delete this picture. This will also delete the picture on your friends profile. This action cannot be undone.\n\n",
                style: TextStyle(fontSize: 15)),
            TextSpan(
                text:
                    "Note: You are able to delete this picture because it was taken with your device. Please archive the picture if you only want to hide it from your profile.",
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic))
          ])),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss the dialog
              },
              child: const Text(
                "Cancel",
                style: TextStyle(fontSize: textButtonSize),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            TextButton(
              onPressed: () async {
                FirebaseFunctions functions = FirebaseFunctions.instance;

                try {
                  final HttpsCallableResult result = await functions
                      .httpsCallable('deletePictureForSessionUsers')
                      .call({
                    'hostId': _userId,
                    'pictureId': _picture.id,
                    'downloadUrl': _picture.fileUrl
                  });

                  _onPictureActionSuccess(_picture.id);
                  debugPrint(
                      '(PictureCardProvider): Picture deletion successful:${result.data}');

                  notifyListeners();
                } catch (e) {
                  debugPrint(
                      '(PictureCardProvider): Error deleting picture: $e');
                  debugPrint(
                      '(PictureCardProvider): Data= {\nhostId: $_userId\npictureId: ${_picture.id}}');
                }
                if (context.mounted) {
                  Navigator.of(dialogContext).pop(); // Dismiss the dialog
                }
              },
              child: const Text('Delete',
                  style:
                      TextStyle(color: Colors.red, fontSize: textButtonSize)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _restorePicture() async {
    await _movePicture(false);
  }

  Future<void> _archivePicture() async {
    await _movePicture(true);
  }

  Future<void> _movePicture(bool archived) async {
    try {
      await Constants.usersCollection
          .doc(_userId)
          .collection(Constants.pictureSubCollection)
          .doc(_picture.id)
          .update({
        Constants.archived: archived,
      });

      debugPrint(
          "(PictureCardProvider): Picture successfully ${isArchived() ? 'restored' : 'archived'}."); // Success message
      _onPictureActionSuccess(_picture.id);
    } catch (e) {
      debugPrint(
          '(PictureCardProvider): Error calling movePicture function: $e');
    }
  }

  Future<void> _showUsernamesDialog(
      BuildContext context, Iterable<dynamic> usernames) async {
    // UserManager and Bubble logic as before
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

  String usersThatLiked() {
    switch (_picture.likes.length) {
      case 1:
        return _picture.likes.first;
      default:
        return '${_picture.likes.first} and others';
    }
  }

  Future<void> showLikesDialog(BuildContext context) async {
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
            children: _picture.likes
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

  Future<bool?> onLike(bool isLiked) async {
    Map<Object, Object?> data;

    if (isLiked) {
      // Action ==> Unlike
      data = {
        Constants.likesDoc: FieldValue.arrayRemove([_connectedUsername]),
      };
    } else {
      // Action ==> Like
      debugPrint('(PictureCardProvider): Is liked yet = $_isNotLikedYet');
      if (_isNotLikedYet) {
        data = {
          Constants.likesDoc: FieldValue.arrayUnion([_connectedUsername]),
          Constants.firstLikesDoc: FieldValue.arrayUnion([_connectedUsername])
        };
        _isNotLikedYet = true;
        PostService.sendPostLikeNotification(_connectedUsername, _userId);
      } else {
        data = {
          Constants.likesDoc: FieldValue.arrayUnion([_connectedUsername]),
        };
      }
    }
    await Constants.usersCollection
        .doc(_userId)
        .collection(Constants.pictureSubCollection)
        .doc(_picture.id)
        .update(data)
        .then((value) {
      debugPrint(
          '(PictureCardProvider): Updated like to ${(!isLiked).toString()}');
    }).onError((error, stackTrace) {
      debugPrint(
          '(PictureCardProvider): Error updating likes= ${error.toString()}');
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (isLiked) {
        _picture.likes.remove(_connectedUsername);
      } else {
        _picture.likes.add(_connectedUsername);
      }
      notifyListeners();
    });
    _isLiked = !_isLiked;

    return _isLiked;
  }
}
