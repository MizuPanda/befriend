import 'package:befriend/views/dialogs/profile/delete_picture_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import '../models/data/user_manager.dart';
import '../models/objects/bubble.dart';
import '../models/objects/picture.dart';
import '../models/services/post_service.dart';
import '../utilities/constants.dart';
import '../views/widgets/profile/more_button.dart';

class PictureCardProvider extends ChangeNotifier {
  Picture _picture;
  final String _connectedUsername;
  final String _userId;
  final bool _isUsersProfile;
  final Function(String) _onPictureActionSuccess;

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

  bool isPictureHost() {
    return _picture.hostId == _userId && _isUsersProfile;
  }

  bool isArchived() {
    return _picture.archived;
  }

  Future<void> onSelectPop(PopSelection value, BuildContext context,
      Iterable<dynamic> usernames) async {
    switch (value) {
      case PopSelection.archive:
        if (isArchived()) {
          await _restorePicture();
        } else {
          await _archivePicture();
        }
        debugPrint('(PictureCardProvider): Archive action tapped');
        break;
      case PopSelection.info:
        _showUsernamesDialog(context, usernames);
        break;
      case PopSelection.delete:
        await _deletePicture(context);
        break;
    }
  }

  Future<void> _deletePicture(BuildContext context) async {
    DeletePictureDialog.showDeletePictureDialog(
      context,
      () async {
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
              '(PictureCardProvider): Picture deletion successful: ${result.data}');
          notifyListeners();
        } catch (e) {
          debugPrint('(PictureCardProvider): Error deleting picture: $e');
          debugPrint(
              '(PictureCardProvider): Data= {\nhostId: $_userId\npictureId: ${_picture.id}}');
        }
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
          "(PictureCardProvider): Picture successfully ${archived ? 'archived' : 'restored'}.");
      _onPictureActionSuccess(_picture.id);
    } catch (e) {
      debugPrint('(PictureCardProvider): Error moving picture: $e');
    }
  }

  Future<void> _showUsernamesDialog(
      BuildContext context, Iterable<dynamic> usernames) async {
    try {
      Bubble bubble = await UserManager.getInstance();

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              title: const Text("People in this picture"),
              children: usernames
                  .map((username) => SimpleDialogOption(
                        child: Text(
                            bubble.username == username ? 'You' : username),
                      ))
                  .toList(),
            );
          },
        );
      }
    } catch (e) {
      debugPrint('(PictureCardProvider): Error showing usernames dialog: $e');
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
    try {
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
                        child: Text(
                            bubble.username == username ? 'You' : username),
                      ))
                  .toList(),
            );
          },
        );
      }
    } catch (e) {
      debugPrint('(PictureCardProvider): Error showing likes dialog: $e');
    }
  }

  Future<bool?> onLike(bool isLiked) async {
    Map<Object, Object?> data;

    if (isLiked) {
      data = {
        Constants.likesDoc: FieldValue.arrayRemove([_connectedUsername]),
      };
    } else {
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
    try {
      await Constants.usersCollection
          .doc(_userId)
          .collection(Constants.pictureSubCollection)
          .doc(_picture.id)
          .update(data);
      debugPrint(
          '(PictureCardProvider): Updated like to ${(!isLiked).toString()}');
    } catch (error) {
      debugPrint(
          '(PictureCardProvider): Error updating likes: ${error.toString()}');
      return null;
    }

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
