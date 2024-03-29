import 'package:befriend/models/data/data_manager.dart';
import 'package:befriend/models/data/data_query.dart';
import 'package:befriend/models/data/picture_query.dart';
import 'package:befriend/models/data/user_manager.dart';
import 'package:befriend/models/objects/friendship_progress.dart';
import 'package:befriend/models/qr/privacy.dart';
import 'package:befriend/models/services/post_service.dart';
import 'package:befriend/models/social/friend_update.dart';
import 'package:befriend/models/social/friendship_update.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:photo_view/photo_view.dart';

import '../models/data/picture_manager.dart';
import '../models/objects/bubble.dart';
import '../models/objects/host.dart';
import '../models/objects/picture.dart';
import '../utilities/constants.dart';

import 'dart:io' show Platform;

class SessionProvider extends ChangeNotifier {
  final Privacy _privacy = Privacy();
  final Host host;
  final Map<String, Bubble> idToBubbleMap;
  final Map<String, double> _sliderValues = {};
  final List<String> ids;
  String? _caption;
  final int _characterLimit = 300; // Set your desired character limit
  bool _isSessionEnded = false;

  int selectedIndex = 0;

  InterstitialAd? _interstitialAd;

  void _loadInterstitialAd() async {
    // Replace with your ad unit ID - TO CHANGE DEPENDENTLY ON PLATFORM
    InterstitialAd.load(
      adUnitId: Platform.isAndroid
          ? Constants.androidTestAdUnit
          : Constants.iosTestAdUnit,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          debugPrint('(SessionProvider): Interstitial Ad Loaded');
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint(
              '(SessionProvider): Interstitial Ad Failed to Load: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  int pointsLength() {
    return _privacy.criticalPoints.length;
  }

  double getPoint() {
    return _privacy.criticalPoints.elementAt(selectedIndex);
  }

  Future<void> showImageFullScreen(
    BuildContext context,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor:
            Colors.transparent, // Make Dialog background transparent
        child: PhotoView(
          tightMode: true,
          backgroundDecoration: const BoxDecoration(
            color: Colors.transparent, // Make PhotoView background transparent
          ),
          // You can adjust the min/max scale if needed
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.contained,
          enableRotation: false,
          imageProvider: networkImage(),
        ),
      ),
    );
  }

  Future<String?> _promptForCaption(BuildContext context) async {
    TextEditingController captionController = TextEditingController();
    return await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          title: const Text('Enter a Caption'),
          content: TextField(
            controller: captionController,
            decoration: InputDecoration(
              hintText: "Caption for the picture",
              counterText:
                  'Characters limit: ${_characterLimit.toString()}', // Optional: Hide the counter text
            ),
            maxLines: null,
            keyboardType: TextInputType.multiline,
            maxLength: _characterLimit, // Enforces the character limit
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Publish'),
              onPressed: () {
                Navigator.of(context).pop(captionController.text.trim());
              },
            ),
          ],
        );
      },
    );
  }

  ImageProvider networkImage() {
    return NetworkImage(
      host.imageUrl!,
    );
  }

  bool imageNull() {
    return host.imageUrl == null;
  }

  Future<void> initPicture() async {
    if (host.main()) {
      await pictureProcess();
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
          _navigateHome(context);
          ad.dispose();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          debugPrint('(SessionProvider): Ad failed to show.');
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

  Future<void> pictureProcess() async {
    await PictureManager.cameraPicture((String? url) {
      host.imagePath = url;
    });
    if (!host.pathNull()) {
      host.imageUrl = await PictureQuery.uploadTempPicture(host, ids);
      host.addCacheFile();
    }
  }

  void processSnapshot(QuerySnapshot snapshot, BuildContext context) {
    bool sliderValuesUpdated = false;
    debugPrint('(SessionProvider): Processing snapshot...');

    if (_isSessionEnded) {
      return;
    }

    if (_sliderValues.isEmpty) {
      for (DocumentSnapshot doc in snapshot.docs) {
        double val = DataManager.getNumber(doc, Constants.sliderDoc).toDouble();
        _sliderValues[doc.id] = val;

        if (doc.id == host.user.id) {
          for (int i = 0; i < _privacy.criticalPoints.length; i++) {
            if (_privacy.criticalPoints.elementAt(i) == val) {
              selectedIndex = i;
              break;
            }
          }
        }
      }
      sliderValuesUpdated = true;
    }

    // Assuming the host document contains a list of user IDs in the session
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
          debugPrint('(SessionProvider): Users: ${sessionUsers.toString()}');

          if (!sessionUsers.contains(host.host.id)) {
            debugPrint('(SessionProvider): No host pop');
            _myPop(context);
          } else if (sessionUsers.length == 1 &&
              sessionUsers.contains(host.user.id)) {
            debugPrint('(SessionProvider): Only 1 user pop');
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
              _loadInterstitialAd();
            }
          } else if (picture == Constants.publishingState) {
            // Navigate back

            debugPrint('(SessionProvider): Picture published pop');
            _goHome(context);
          }
        } else {
          debugPrint('(SessionProvider): Else pop');
          _myPop(context);
        }

        break;
      }
    }
  }

  Future<String> getFriendshipsMap() async {
    if (host.friendshipsMap.isEmpty) {
      DocumentSnapshot documentSnapshot =
          await DataManager.getData(id: host.host.id);

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

      _privacy.setCriticalPoints(host);
    }

    return 'Completed';
  }

  void showFriendList(BuildContext context) {
    _privacy.showFriendList(
        context, host, _sliderValues, (userId) => bubble(userId));
  }

  void _updateUsersList(List<dynamic> sessionUsers, BuildContext context) {
    debugPrint(
        '(SessionProvider): Removing a user. \nList1: ${sessionUsers.toString()}\nList2: ${ids.toString()} ');

    // Remove users who left
    ids.removeWhere((id) => (!sessionUsers.contains(id)));

    if (!ids.contains(host.user.id)) {
      debugPrint('(SessionProvider): User removed pop');
      _myPop(context);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        notifyListeners();
      });
    }
  }

  Future<void> publishPicture(BuildContext context) async {
    _caption = await _promptForCaption(context);
    if (_caption != null) {
      List<String> sessionUsers = ids;

      host.joiners = host.joiners
          .where((element) => sessionUsers.contains(element.id))
          .toList();

      debugPrint('(SessionProvider): Publishing to $sessionUsers');
      final DateTime timestamp = DateTime.timestamp();

      // CALCULATE PRIVACY AND USERS THAT WILL BE ABLE TO SEE IT
      _privacy.calculateAllowedUsers(host, _sliderValues, bubble);

      // CREATE FRIENDSHIPS
      await _createOrUpdateFriendships(host.joiners, timestamp);

      // PUBLISH PICTURE
      await _uploadPicture(sessionUsers, host.joiners, timestamp);

      // SET NEW USER DATA FOR EVERY USER
      await _setUsersData(sessionUsers, host.joiners, timestamp);

      // SEND NOTIFICATIONS. Note: Add a friendsListening array field doc in users doc. Start it empty. If user press on...
      _sendNotificationsToUser(sessionUsers, host.joiners);
    }
  }

  void _sendNotificationsToUser(List<dynamic> sessionUsers,
      Iterable<Bubble> joinersStillConnected) async {
    Set<dynamic> usersToNotify = {};

    // If PUBLIC    --> Add all friends of sessionUsers, except sessionUsers
    // If PRIVATE   --> Do nothing.
    // If Moderated --> Add friendsAllowed
    if (_privacy.isPublic) {
      for (Bubble joiner in joinersStillConnected) {
        usersToNotify.addAll(joiner.friendIDs
            .where((element) => !sessionUsers.contains(element)));
      }
    } else if (!_privacy.isPrivate) {
      usersToNotify.addAll(_privacy.friendsAllowed);
    }

    // Future, but not useful to screen or anything
    PostService.sendPostNotification(
        usersToNotify.toList(), host.host.username, host.host.id);
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
                userID1, userID2, friendshipDoc, timestamp,
                exp: Constants.pictureExpValue);
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
                timestamp: timestamp);

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
    List<dynamic> usersAllowed = [];

    // Three possible states
    // Private, Moderated, Public
    if (!_privacy.isPublic) {
      usersAllowed.addAll(sessionUsers);

      if (!_privacy.isPrivate) {
        List<String> friendsAllowed = _privacy.friendsAllowed.toList();
        usersAllowed.addAll(friendsAllowed);
      }
    }

    // Move picture to the posted folder
    String? downloadUrl =
        await PictureQuery.movePictureToPermanentStorage(host);
    host.imageUrl = downloadUrl;
    debugPrint('(SessionProvider): Moved picture to $downloadUrl');

    Map<String, String> sessionUsersMap = {};

    for (Bubble bubble in joinersStillConnected) {
      sessionUsersMap[bubble.id] = bubble.username;
    }

    // Create a Picture object
    Picture picture = Picture.newPicture(
        host.imageUrl!,
        host.host.id,
        host.host.username,
        timestamp,
        host.tempFile(),
        _privacy.isPublic,
        _caption!,
        usersAllowed,
        sessionUsersMap);

    String id = '';

    for (String userID in sessionUsers) {
      if (id.isEmpty) {
        // Save the picture to the user's sub collection
        DocumentReference ref = await Constants.usersCollection
            .doc(userID)
            .collection(Constants.pictureSubCollection)
            .add(picture.toMap());
        id = ref.id;
      } else {
        await Constants.usersCollection
            .doc(userID)
            .collection(Constants.pictureSubCollection)
            .doc(id)
            .set(picture.toMap());
      }
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
        debugPrint('(SessionProvider): Resetting Host Data');
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
    debugPrint('(SessionProvider): Quitting lobby');

    if (host.main()) {
      await _resetData();
    }

    await Constants.usersCollection.doc(host.host.id).update({
      Constants.hostingDoc: FieldValue.arrayRemove([host.user.id]),
    });
  }

  Future<void> _resetData() async {
    debugPrint('(SessionProvider): Resetting Data');

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
