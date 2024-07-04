import 'package:befriend/models/data/data_manager.dart';
import 'package:befriend/models/data/data_query.dart';
import 'package:befriend/models/data/picture_query.dart';
import 'package:befriend/models/data/user_manager.dart';
import 'package:befriend/models/objects/friendship_progress.dart';
import 'package:befriend/models/services/post_service.dart';
import 'package:befriend/models/social/friend_update.dart';
import 'package:befriend/models/social/friendship_update.dart';
import 'package:befriend/utilities/error_handling.dart';
import 'package:befriend/utilities/models.dart';
import 'package:befriend/views/dialogs/session/caption_dialog.dart';
import 'package:befriend/views/dialogs/session/fullscreen_image_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

import '../models/data/picture_manager.dart';
import '../models/objects/bubble.dart';
import '../models/objects/host.dart';
import '../models/objects/picture.dart';
import '../utilities/app_localizations.dart';
import '../utilities/constants.dart';

import 'dart:io' show Platform;

import '../utilities/secrets.dart';

class SessionProvider extends ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  final Host host;
  final Map<String, Bubble> idToBubbleMap;
  final Map<String, double> _sliderValues = {};
  final List<String> ids;
  String? _caption;
  final int _characterLimit = 300; // Set your desired character limit
  bool _isSessionEnded = false;

  int selectedIndex = 0;

  InterstitialAd? _interstitialAd;

  final GlobalKey _one = GlobalKey(); // Hold picture (Host)
  final GlobalKey _two = GlobalKey(); // Press picture
  final GlobalKey _three = GlobalKey(); // Privacy
  final GlobalKey _four = GlobalKey(); // Who will see
  final GlobalKey _five = GlobalKey(); // Publish (Host)

  GlobalKey get one => _one;
  GlobalKey get two => _two;
  GlobalKey get three => _three;
  GlobalKey get four => _four;
  GlobalKey get five => _five;

  bool showTutorial = false;

  void _initShowcase(BuildContext context, bool showTutorial) {
    if (showTutorial) {
      WidgetsBinding.instance.addPostFrameCallback((_) => showCase(context));
    }
  }

  void showCase(BuildContext context) {
    ShowCaseWidget.of(context).startShowCase(host.main()
        ? [_one, _two, _three, _four, _five]
        : [
            _two,
            _three,
            _four,
          ]);
  }

  void _loadInterstitialAd() async {
    // Replace with your ad unit ID - TO CHANGE DEPENDENTLY ON PLATFORM
    final String adUnitId = /*Platform.isAndroid
        ? Secrets.sessionAndroidAdTile
        : Secrets.sessioniOSAdTile;*/
    Platform.isAndroid
          ? Constants.sessionAndroidTestAdUnit
          : Constants.sessioniOSTestAdUnit;

    debugPrint('(SessionProvider) Ad Unit= $adUnitId');
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          debugPrint('(SessionProvider) Interstitial Ad Loaded');
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint(
              '(SessionProvider) Interstitial Ad Failed to Load: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  int pointsLength() {
    return host.pointsLength();
  }

  Set<double> criticalPoints() {
    return host.criticalPoints();
  }

  double getPoint() {
    return host.getPoint(selectedIndex);
  }

  Future<void> showImageFullScreen(
    BuildContext context,
  ) async {
    await FullscreenImageDialog.showImageFullScreen(context, networkImage());
  }

  Future<String?> _promptForCaption(BuildContext context) async {
    try {
      return await CaptionDialog.showCaptionDialog(context, _characterLimit);
    } catch (e) {
      debugPrint('(SessionProvider) Error prompting for caption: $e');
      return null;
    }
  }

  NetworkImage networkImage() {
    return NetworkImage(
      host.imageUrl!,
    );
  }

  bool imageNull() {
    return host.imageUrl == null;
  }

  Future<void> initPicture(BuildContext context) async {
    if (host.main()) {
      await pictureProcess(context);
    }
  }

  void _myPop(BuildContext context) {
    _isSessionEnded = true;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      GoRouter.of(context).pop();
    });
  }

  Future<void> _goHome(BuildContext context) async {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          debugPrint('(SessionProvider) Ad showed successfully.');
          _navigateHome(context);
          ad.dispose();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          debugPrint('(SessionProvider) Ad failed to show.');
          _navigateHome(context);
          ad.dispose();
        },
      );

      _interstitialAd!.show();
      _interstitialAd = null; // Reset for next ad load
    } else {
      // No ad loaded, proceed as normal
      _navigateHome(context);
    }
  }

  Future<void> _navigateHome(BuildContext context) async {
    _isSessionEnded = true;

    await UserManager.reloadHome(context);
  }

  Future<void> pictureProcess(BuildContext context) async {
    try {
      await PictureManager.cameraPicture(context, (String? url) {
        host.imagePath = url;
      });
      if (!host.pathNull()) {
        host.imageUrl = await PictureQuery.uploadTempPicture(host, ids);
        host.addCacheFile();
      }
    } catch (e) {
      debugPrint('(SessionProvider) Error in pictureProcess: $e');
    }
  }

  void processSnapshot(QuerySnapshot snapshot, BuildContext context) {
    try {
      bool sliderValuesUpdated = false;
      debugPrint('(SessionProvider) Processing snapshot...');

      if (_isSessionEnded) {
        return;
      }

      if (_sliderValues.isEmpty) {
        for (DocumentSnapshot doc in snapshot.docs) {
          double val =
              DataManager.getNumber(doc, Constants.sliderDoc).toDouble();
          _sliderValues[doc.id] = val;

          if (doc.id == host.user.id) {
            for (int i = 0; i < host.pointsLength(); i++) {
              if (host.getPoint(i) == val) {
                selectedIndex = i;
                break;
              }
            }
          }
        }
        sliderValuesUpdated = true;
      }

      for (DocumentChange docChange in snapshot.docChanges) {
        if (!sliderValuesUpdated) {
          _sliderValues[docChange.doc.id] =
              DataManager.getNumber(docChange.doc, Constants.sliderDoc)
                  .toDouble();
        }
        if (docChange.doc.id == host.host.id) {
          List<dynamic> sessionUsers = docChange.doc[Constants.hostingDoc];
          if (sessionUsers.isNotEmpty) {
            String picture = sessionUsers.first.toString();
            sessionUsers = sessionUsers.skip(1).toList();
            debugPrint('(SessionProvider) Users: ${sessionUsers.toString()}');

            if (!sessionUsers.contains(host.host.id)) {
              debugPrint('(SessionProvider) No host pop');
              _myPop(context);
            } else if (sessionUsers.length == 1 &&
                sessionUsers.contains(host.user.id)) {
              debugPrint('(SessionProvider) Only 1 user pop');
              _myPop(context);
            } else if (sessionUsers.length != ids.length) {
              _updateUsersList(sessionUsers, context);
            } else if (picture.startsWith(Constants.pictureMarker) &&
                !picture.contains(host.imageUrl ?? 'potato123456789')) {
              picture = picture.substring(Constants.pictureMarker.length);
              host.imageUrl = picture;

              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                notifyListeners();
              });
              if (_interstitialAd == null) {
                debugPrint('(SessionProvider) Interstitial Ad Not Null');
                _loadInterstitialAd();
              }
            } else if (picture == Constants.publishingState) {
              debugPrint('(SessionProvider) Picture published pop');
              _goHome(context);
            }
          } else {
            debugPrint('(SessionProvider) Else pop');
            _myPop(context);
          }

          break;
        }
      }
    } catch (e) {
      debugPrint('(SessionProvider) Error processing snapshot: $e');
    }
  }

  Future<String> getFriendshipsMap(BuildContext context) async {
    if (host.friendshipsMap.isEmpty) {
      DocumentSnapshot documentSnapshot =
          await Models.dataManager.getData(id: host.host.id);

      Map<String, dynamic> friendshipsMap = documentSnapshot
              .data()
              .toString()
              .contains(Constants.hostingFriendshipsDoc)
          ? documentSnapshot.get(Constants.hostingFriendshipsDoc)
          : {};

      // Map of users and their friendList
      for (MapEntry<String, dynamic> sessionUserData
          in friendshipsMap.entries) {
        List<FriendshipProgress> friendships = [];
        for (Map<String, dynamic> friendMap in sessionUserData.value) {
          FriendshipProgress friendship =
              FriendshipProgress.fromMap(friendMap, sessionUserData.key);
          friendships.add(friendship);
        }
        host.friendshipsMap[sessionUserData.key] = friendships;
      }

      host.setCriticalPoints();
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Remove data for the 'counter' key.

    if (host.main()) {
      // await prefs.remove(Constants.showSessionHostTutorialKey); // For testing

      showTutorial =
          prefs.getBool(Constants.showSessionHostTutorialKey) ?? true;
      if (showTutorial) {
        prefs.setBool(Constants.showSessionHostTutorialKey, false);
      }
    } else {
      // await prefs.remove(Constants.showSessionJoinerTutorialKey); // For testing

      showTutorial =
          prefs.getBool(Constants.showSessionJoinerTutorialKey) ?? true;
      if (showTutorial) {
        prefs.setBool(Constants.showSessionJoinerTutorialKey, false);
      }
    }

    if (context.mounted) {
      _initShowcase(context, showTutorial);
    }

    return 'Completed';
  }

  void showFriendList(BuildContext context) {
    host.showFriendList(context, _sliderValues, (userId) => bubble(userId));
  }

  void _updateUsersList(List<dynamic> sessionUsers, BuildContext context) {
    debugPrint(
        '(SessionProvider) Removing a user. \nList1: ${sessionUsers.toString()}\nList2: ${ids.toString()} ');

    // Remove users who left
    ids.removeWhere((id) => (!sessionUsers.contains(id)));

    if (!ids.contains(host.user.id)) {
      debugPrint('(SessionProvider) User removed pop');
      _myPop(context);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        notifyListeners();
      });
    }
  }

  Future<void> publishPicture(BuildContext context) async {
    try {
      _caption = await _promptForCaption(context);
      if (_caption != null) {
        _isLoading = true;
        notifyListeners();

        List<String> sessionUsers = ids;

        host.joiners = host.joiners
            .where((element) => sessionUsers.contains(element.id))
            .toList();

        debugPrint('(SessionProvider) Publishing to $sessionUsers');
        final DateTime timestamp = DateTime.timestamp();

        host.calculateAllowedUsers(_sliderValues, bubble);
        await _createOrUpdateFriendships(host.joiners, timestamp);
        await _uploadPicture(sessionUsers, host.joiners, timestamp);
        await _setUsersData(sessionUsers, host.joiners, timestamp);
        if (context.mounted) {
          _sendNotificationsToUser(sessionUsers, host.joiners, context);
        }

        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('(SessionProvider) Error publishing picture: $e');
      _isLoading = false;
      notifyListeners();
      if (context.mounted) {
        ErrorHandling.showError(
            context, AppLocalizations.of(context)?.translate('sp_publish_error')??'Error publishing picture. Please try again.');
      }
    }
  }

  void _sendNotificationsToUser(List<dynamic> sessionUsers,
      Iterable<Bubble> joinersStillConnected, BuildContext context) async {
    Set<dynamic> usersToNotify = {};
    Map<String, List<String>> notificationMap = {};

    // If PUBLIC    --> Add all friends of sessionUsers, except sessionUsers
    // If PRIVATE   --> Do nothing.
    // If Moderated --> Add friendsAllowed
    if (host.isPublic()) {
      for (Bubble joiner in joinersStillConnected) {
        usersToNotify.addAll(joiner.friendIDs
            .where((element) => !sessionUsers.contains(element)));
      }
    } else if (!host.isPrivate()) {
      usersToNotify.addAll(host.friendsAllowed());
    }

    // Create the map <String, List<String>>
    for (String user in usersToNotify) {
      for (Bubble joiner in joinersStillConnected) {
        if (joiner.friendIDs.contains(user)) {
          if (!notificationMap.containsKey(joiner.id)) {
            notificationMap[joiner.id] = [];
          }
          if (!notificationMap[joiner.id]!.contains(user)) {
            notificationMap[joiner.id]!.add(user);
          }
          break; // Ensure each userToNotify is only attributed to the first friend
        }
      }
    }

    // Send notifications
    notificationMap.forEach((senderId, friendsList) {
      PostService.sendPostNotification(
          friendsList, host.host.username, senderId, context);
    });
  }

  Future<void> _createOrUpdateFriendships(
      List<Bubble> joiners, DateTime timestamp) async {
    for (int i = 0; i < joiners.length; i++) {
      for (int j = i + 1; j < joiners.length; j++) {
        String userID1 = joiners[i].id; // Assuming each user has an 'id' field
        String userID2 = joiners[j].id;

        // Verifying if one user is blocking the other one.
        if (!joiners[i].blockedUsers.keys.contains(userID2) &&
            !joiners[i].blockedUsers.keys.contains(userID1)) {
          // Ensure the IDs are in alphabetical order for the document ID
          List<String> ids = [userID1, userID2];
          ids.sort();
          String friendshipDocId = ids.join();

          // Check if the friendship already exists
          DocumentSnapshot friendshipDoc =
              await Constants.friendshipsCollection.doc(friendshipDocId).get();

          if (friendshipDoc.exists) {
            // Update existing friendship
            await FriendshipUpdate.addProgress(
                userID1, userID2, friendshipDoc,
                exp: Constants.pictureExpValue,

            );
          } else {
            // Create a new friendship
            String username1 = idToBubbleMap[userID1]!.username;
            String username2 = idToBubbleMap[userID2]!.username;

            await FriendshipUpdate.createFriendship(
                userID1: userID1,
                userID2: userID2,
                username1: username1,
                username2: username2,
                friendshipDocId: friendshipDocId,
              baseProgress: Constants.pictureExpValue
            );

            // Update both users 'friendships document'
            await FriendUpdate.addFriend(userID2, mainUserId: userID1);
            await FriendUpdate.addFriend(userID1, mainUserId: userID2);
          }
        }
      }
    }
  }

  Future<void> _uploadPicture(
    List<String> sessionUsers,
    List<Bubble> joinersStillConnected,
    DateTime timestamp,
  ) async {
    try {
      List<dynamic> usersAllowed = [];

      Iterable<String> notArchivedUsers = sessionUsers.map((sessionUser) => '${Constants.notArchived}$sessionUser');

      usersAllowed.addAll(notArchivedUsers);
      List<String> friendsAllowed = host.friendsAllowed().toList();
      usersAllowed.addAll(friendsAllowed);

      String? downloadUrl =
          await PictureQuery.movePictureToPermanentStorage(host);
      host.imageUrl = downloadUrl;
      debugPrint('(SessionProvider) Moved picture to $downloadUrl');

      Map<String, String> sessionUsersMap = {};

      for (Bubble bubble in joinersStillConnected) {
        sessionUsersMap[bubble.id] = bubble.username;
      }

      Picture picture = Picture.newPicture(
          host.imageUrl!,
          host.host.id,
          host.host.username,
          timestamp,
          host.tempFile(),
          host.isPublic(),
          _caption!,
          usersAllowed,
          sessionUsersMap);

      await Constants.picturesCollection
          .add(picture.toMap());
    } catch (e) {
      debugPrint('(SessionProvider) Error uploading picture: $e');

      rethrow;
    }
  }

  Future<void> _setUsersData(List<dynamic> sessionUsers,
      Iterable<Bubble> joinersStillConnected, DateTime timestamp) async {
    List<dynamic> lst = [(Constants.publishingState)];
    lst.addAll(sessionUsers);

    for (Bubble joiner in joinersStillConnected) {
      if (!kDebugMode) {
        for (Bubble otherJoiner in joinersStillConnected) {
          // If another user -->
          if (otherJoiner.id != joiner.id) {
            joiner.lastSeenUsersMap[otherJoiner.id] = timestamp;
          }
        }
      }

      if (joiner == host.host) {
        debugPrint('(SessionProvider) Resetting Host Data');
        // SET HOST INDEX TO PUBLISHING STATE, WHICH NOTIFIES USERS THAT THE PICTURE HAS BEEN UPLOADED
        await Constants.usersCollection.doc(joiner.id).update({
          Constants.hostingDoc: lst,
          Constants.hostingFriendshipsDoc: {},
          Constants.lastSeenUsersMapDoc: joiner.lastSeenUsersMap,
        });

        await PictureQuery.deleteTemporaryPictures(host);
        host.clearTemporaryFiles();
      } else {
        await DataQuery.updateDocument(
            userId: joiner.id,
            Constants.lastSeenUsersMapDoc,
            joiner.lastSeenUsersMap);
      }
    }
  }

  Future<void> cancelLobby(BuildContext context) async {
    debugPrint('(SessionProvider) Quitting lobby');

    if (host.main()) {
      await _resetData();
    }

    await Constants.usersCollection.doc(host.host.id).update({
      Constants.hostingDoc: FieldValue.arrayRemove([host.user.id]),
    });
  }

  Future<void> _resetData() async {
    debugPrint('(SessionProvider) Resetting Data');

    await Constants.usersCollection.doc(host.host.id).update({
      Constants.hostingFriendshipsDoc: {},
    });
    await PictureQuery.deleteTemporaryPictures(host);

    host.clearTemporaryFiles();
  }

  SessionProvider._(
      {required this.host, required this.idToBubbleMap, required this.ids});

  factory SessionProvider.builder(
    Host host,
  ) {
    Map<String, Bubble> idToBubbleMap = {
      for (Bubble bubble in host.joiners) bubble.id: bubble
    };
    List<String> ids = idToBubbleMap.keys.toList();

    return SessionProvider._(
        host: host, idToBubbleMap: idToBubbleMap, ids: ids);
  }

  Bubble? bubble(String id) {
    return idToBubbleMap[id];
  }

  double sliderValue(String id) {
    return _sliderValues[id] ?? 0;
  }

  String hostUsername() {
    return host.host.username;
  }

  bool isUser(String id) {
    return host.user.id == id;
  }

  int length() {
    return ids.length;
  }
}
