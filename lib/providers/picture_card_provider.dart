import 'package:befriend/models/authentication/authentication.dart';
import 'package:befriend/models/services/share_service.dart';
import 'package:befriend/views/dialogs/profile/delete_picture_dialog.dart';
import 'package:befriend/views/dialogs/profile/likes_dialog.dart';
import 'package:befriend/views/dialogs/profile/username_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/objects/picture.dart';
import '../models/services/post_service.dart';
import '../utilities/app_localizations.dart';
import '../utilities/constants.dart';
import '../views/dialogs/profile/report_dialog.dart';
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

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ReportDialog(
        pictureId: _picture.id,
        profileId: _userId,
        sessionUsers: _picture.sessionUsers,
      ),
    );
  }

  bool isArchived() {
    return _picture.hasUserArchived();
  }

  Future<void> onSelectPop(PopSelection value, BuildContext context,
      Iterable<dynamic> usernames) async {
    switch (value) {
      case PopSelection.archive:
        if (isArchived()) {
          await _toggleArchive(false);
        } else {
          await _toggleArchive(true);
        }
        debugPrint('(PictureCardProvider) Archive action tapped');
        break;
      case PopSelection.info:
        UsernameDialog.showUsernamesDialog(context, usernames);
        break;
      case PopSelection.report:
        _showReportDialog(context);
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
              '(PictureCardProvider) Picture deletion successful: ${result.data}');
          notifyListeners();
        } catch (e) {
          debugPrint('(PictureCardProvider) Error deleting picture: $e');
          debugPrint(
              '(PictureCardProvider) Data= {\nhostId: $_userId\npictureId: ${_picture.id}}');
        }
      },
    );
  }

  Future<void> _toggleArchive(bool archived) async {
    try {
      String archivedID = AuthenticationManager.archivedID();
      String notArchivedID = AuthenticationManager.notArchivedID();

      String add = archived ? archivedID : notArchivedID;
      String remove = archived ? notArchivedID : archivedID;

      await Constants.picturesCollection.doc(_picture.id).update({
        Constants.allowedUsersDoc: FieldValue.arrayRemove([remove]),
      });
      await Constants.picturesCollection.doc(_picture.id).update({
        Constants.allowedUsersDoc: FieldValue.arrayUnion([add])
      });
      debugPrint(
          "(PictureCardProvider) Picture successfully ${archived ? 'archived' : 'restored'}.");
      _onPictureActionSuccess(_picture.id);
    } catch (e) {
      debugPrint('(PictureCardProvider) Error moving picture: $e');
    }
  }

  String usersThatLiked(BuildContext context) {
    switch (_picture.likes.length) {
      case 1:
        return _picture.likes.first;
      default:
        return '${_picture.likes.first} ${AppLocalizations.of(context)?.translate('pcp_others') ?? 'and others'}';
    }
  }

  Future<void> showLikesDialog(BuildContext context) async {
    await LikesDialog.showLikesDialog(context, _picture.likes);
  }

  Future<bool?> onLike(bool isLiked) async {
    Map<Object, Object?> data;

    if (isLiked) {
      data = {
        Constants.likesDoc: FieldValue.arrayRemove([_connectedUsername]),
      };
    } else {
      debugPrint('(PictureCardProvider) Is liked yet = $_isNotLikedYet');
      String connectedUserID = AuthenticationManager.id();

      if (_isNotLikedYet) {
        data = {
          Constants.likesDoc: FieldValue.arrayUnion([_connectedUsername]),
          Constants.firstLikesDoc: FieldValue.arrayUnion([_connectedUsername])
        };
        _isNotLikedYet = true;

        if (!_picture.sessionUsers.containsKey(connectedUserID)) {
          List<String> usersToNotify = _picture.sessionUsers.keys.toList();

          debugPrint('(PictureCardProvider) Sending notification');

          PostService.sendPostLikeNotification(
              _connectedUsername, usersToNotify);
        }
      } else {
        data = {
          Constants.likesDoc: FieldValue.arrayUnion([_connectedUsername]),
        };
      }
    }
    try {
      Constants.picturesCollection.doc(_picture.id).update(data);
      debugPrint(
          '(PictureCardProvider) Updated like to ${(!isLiked).toString()}');
    } catch (error) {
      debugPrint(
          '(PictureCardProvider) Error updating likes: ${error.toString()}');
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

  String formatDate(DateTime date, BuildContext context) {
    // This method converts the DateTime into a more readable string
    // Adjust the formatting to fit your needs
    // Get the current locale
    Locale currentLocale = Localizations.localeOf(context);

    // Create a DateFormat instance with the current locale
    DateFormat dateFormat = DateFormat.yMd(currentLocale.toString());

    return dateFormat.format(date);
  }

  Uri shareLink() {
    return ShareService.generatePostShareLink(_picture.id, _userId);
  }
}
