import 'package:befriend/models/authentication/authentication.dart';
import 'package:befriend/models/data/data_manager.dart';
import 'package:befriend/models/data/data_query.dart';
import 'package:befriend/models/data/user_manager.dart';
import 'package:befriend/models/services/share_service.dart';
import 'package:befriend/views/dialogs/profile/delete_picture_dialog.dart';
import 'package:befriend/views/dialogs/profile/likes_dialog.dart';
import 'package:befriend/views/dialogs/profile/set_private_dialog.dart';
import 'package:befriend/views/dialogs/profile/username_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/objects/bubble.dart';
import '../models/objects/picture.dart';
import '../models/services/post_service.dart';
import '../utilities/app_localizations.dart';
import '../utilities/constants.dart';
import '../views/dialogs/profile/report_dialog.dart';
import '../views/widgets/profile/more_button.dart';

class PictureCardProvider extends ChangeNotifier {
  Picture _picture;
  final String _userId;
  final bool _isUsersProfile;
  final Function(String) _onPictureActionSuccess;

  PictureCardProvider(
    this._picture,
    this._userId,
    this._isUsersProfile,
    this._onPictureActionSuccess,
  );

  bool _isLiked = false;
  late bool _isNotLikedYet;

  bool get isLiked => _isLiked;
  bool get isUsersProfile => _isUsersProfile;

  void initLikes() {
    _isLiked = _picture.likes.contains(AuthenticationManager.id());
    _isNotLikedYet = !_picture.firstLikes.contains(AuthenticationManager.id());
  }

  void updatePicture(Picture picture) {
    _picture = picture;
  }

  bool isPictureHost() {
    return _picture.hostId == _userId && _isUsersProfile;
  }

  bool isPicturePublic() {
    return _picture.isPublic &&
        (_picture.sessionUsers.contains(AuthenticationManager.id()));
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
      List<dynamic> sessionUsers) async {
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
        final List<Bubble> users = [];

        for (String id in sessionUsers) {
          Bubble bubble;
          if (id == AuthenticationManager.id()) {
            bubble = await UserManager.getInstance();
          } else {
            final DocumentSnapshot doc = await DataManager.getData(id: id);
            final ImageProvider avatar = await DataManager.getAvatar(doc);

            bubble = Bubble.fromDocs(doc, avatar);
          }

          users.add(bubble);
        }

        if (context.mounted) {
          UsernameDialog.showUsernamesDialog(context, users);
        }
        break;
      case PopSelection.report:
        _showReportDialog(context);
        break;
      case PopSelection.delete:
        await _deletePicture(context);
        break;
      case PopSelection.public:
        await _setToPrivate(context);
        break;
    }
  }

  Future<void> _setToPrivate(BuildContext context) async {
    SetPrivateDialog.dialog(context, _picture.id, _onPictureActionSuccess);
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

  Future<String> usersThatLiked(BuildContext context) async {
    switch (_picture.likes.length) {
      case 1:
        return await DataQuery.getUsername(_picture.likes.first);
      default:
        return '${await DataQuery.getUsername(_picture.likes.first)} ${context.mounted ? AppLocalizations.translate(context, key: 'pcp_others', defaultString: 'and others') : 'and others'}';
    }
  }

  Future<void> showLikesDialog(BuildContext context) async {
    await LikesDialog.showLikesDialog(context, _picture.likes);
  }

  Future<bool?> onLike(bool isLiked) async {
    Map<Object, Object?> data;

    if (isLiked) {
      data = {
        Constants.likesDoc:
            FieldValue.arrayRemove([AuthenticationManager.id()]),
      };
    } else {
      debugPrint('(PictureCardProvider) Is liked yet = $_isNotLikedYet');
      String connectedUserID = AuthenticationManager.id();

      if (_isNotLikedYet) {
        data = {
          Constants.likesDoc: FieldValue.arrayUnion([connectedUserID]),
          Constants.firstLikesDoc: FieldValue.arrayUnion([connectedUserID])
        };
        _isNotLikedYet = true;

        if (!_picture.sessionUsers.contains(connectedUserID)) {
          List<dynamic> usersToNotify = _picture.sessionUsers;

          debugPrint('(PictureCardProvider) Sending notification');

          final Bubble currentUser = await UserManager.getInstance();

          PostService.sendPostLikeNotification(
              currentUser.username, usersToNotify);
        }
      } else {
        data = {
          Constants.likesDoc: FieldValue.arrayUnion([connectedUserID]),
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
        _picture.likes.remove(AuthenticationManager.id());
      } else {
        _picture.likes.add(AuthenticationManager.id());
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
