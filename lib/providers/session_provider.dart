import 'package:befriend/models/data/data_manager.dart';
import 'package:befriend/models/data/data_query.dart';
import 'package:befriend/models/data/picture_query.dart';
import 'package:befriend/models/objects/friendship_progress.dart';
import 'package:befriend/models/qr/host_listening.dart';
import 'package:befriend/models/qr/privacy.dart';
import 'package:befriend/models/social/friend_update.dart';
import 'package:befriend/models/social/friendship_update.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';

import '../models/data/picture_manager.dart';
import '../models/objects/bubble.dart';
import '../models/objects/host.dart';
import '../models/objects/picture.dart';
import '../utilities/constants.dart';

class SessionProvider extends ChangeNotifier {
  final Privacy _privacy = Privacy();
  final Host host;
  final Map<String, Bubble> idToBubbleMap;
  final Map<String, double> _sliderValues = {};
  final List<String> ids;
  String? _caption;
  final int _characterLimit = 300; // Set your desired character limit

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

  Future<void> disposeSession() async {
    if (host.main()) {
      HostListening.setPictureToFalse();
    }
    await HostListening.onDispose(host);

    dispose();
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

    if (_sliderValues.isEmpty) {
      for (DocumentSnapshot doc in snapshot.docs) {
        _sliderValues[doc.id] =
            DataManager.getNumber(doc, Constants.sliderDoc).toDouble();
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
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              GoRouter.of(context).pop();
            });
          } else if (sessionUsers.length != ids.length) {
            _updateUsersList(sessionUsers);
          } else if (picture.startsWith(Constants.pictureMarker) &&
              !picture.contains(host.imageUrl ?? 'potato123456789')) {
            picture = picture.substring(Constants.pictureMarker.length);
            host.imageUrl = picture;

            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              notifyListeners();
            });
          } else if (picture == Constants.publishingState) {
            // Navigate back
            WidgetsBinding.instance.addPostFrameCallback((_) {
              GoRouter.of(context).pop();
            });
          }
        }

        break;
      }
    }
  }

  Future<void> getFriendshipsMap() async {
    if (host.friendshipsMap.isEmpty) {
      DocumentSnapshot documentSnapshot =
          await DataManager.getData(id: host.host.id);

      Map<String, dynamic> map = documentSnapshot
              .data()
              .toString()
              .contains(Constants.hostingFriendships)
          ? documentSnapshot.get(Constants.hostingFriendships)
          : {};

      for (MapEntry<String, dynamic> user in map.entries) {
        List<FriendshipProgress> friendships = [];
        for (Map<String, dynamic> friendMap in user.value) {
          FriendshipProgress friendship = FriendshipProgress.fromMap(friendMap);
          friendships.add(friendship);
        }
        host.friendshipsMap[user.key] = friendships;
      }
    }
  }

  void showFriendList(BuildContext context) {
    _privacy.showFriendList(
        context, host, _sliderValues, (userId) => bubble(userId));
  }

  void _updateUsersList(
    List<dynamic> sessionUsers,
  ) {
    debugPrint(
        '(SessionProvider): Removing a user. \nList1: ${sessionUsers.toString()}\nList2: ${ids.toString()} ');
    // Remove users who left
    ids.removeWhere((id) => (!sessionUsers.contains(id)));

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      notifyListeners();
    });
  }

  Future<void> publishPicture(BuildContext context) async {
    _caption = await _promptForCaption(context);
    if (_caption != null) {
      List<String> sessionUsers = host.joiners.map((e) => e.id).toList();
      final DateTime timestamp = DateTime.timestamp();

      // CALCULATE PRIVACY AND USERS THAT WILL BE ABLE TO SEE IT
      _privacy.calculateAllowedUsers(host, _sliderValues, bubble);

      // CREATE FRIENDSHIPS
      await _createOrUpdateFriendships(sessionUsers, timestamp);

      // PUBLISH PICTURE
      await _uploadPicture(sessionUsers, timestamp);

      // SET HOST INDEX TO PUBLISHING STATE, WHICH NOTIFIES USERS THAT THE PICTURE HAS BEEN UPLOADED
      List<dynamic> lst = [(Constants.publishingState)];
      lst.addAll(ids);
      await DataQuery.updateDocument(Constants.hostingDoc, lst);
    }
  }

  Future<void> _createOrUpdateFriendships(
      List<dynamic> sessionUsers, DateTime timestamp) async {
    for (int i = 0; i < sessionUsers.length; i++) {
      for (int j = i + 1; j < sessionUsers.length; j++) {
        String userID1 =
            sessionUsers[i]; // Assuming each user has an 'id' field
        String userID2 = sessionUsers[j];

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

  Future<void> _uploadPicture(
    List<dynamic> sessionUsers,
    DateTime timestamp,
  ) async {
    List<dynamic> usersAllowed = [];

    // Three possible states
    // Private, Moderated, Public
    if (!_privacy.isPublic) {
      usersAllowed.addAll(sessionUsers);

      if (!_privacy.isPrivate) {
        usersAllowed.addAll(_privacy.friendsAllowed.toList());
      }
    }

    // Move picture to the posted folder
    String? downloadUrl =
        await PictureQuery.movePictureToPermanentStorage(host);
    host.imageUrl = downloadUrl;
    debugPrint('(SessionProvider): Moved picture to $downloadUrl');

    // Create a Picture object
    PictureData picture = PictureData.newPicture(host.imageUrl!, host.user.name,
        timestamp, host.tempFile(), _privacy.isPublic, _caption!, usersAllowed);

    for (String userID in sessionUsers) {
      // Save the picture to the user's subcollection
      await Constants.usersCollection
          .doc(userID)
          .collection(Constants.pictureSubCollection)
          .add(picture.toMap());
    }
  }

  Future<void> cancelLobby(BuildContext context) async {
    if (host.main()) {
      // If the host quits, clear the list
      await Constants.usersCollection.doc(host.host.id).update({
        Constants.hostingDoc: FieldValue.arrayRemove([host.host.id])
      });
    } else {
      // If a joiner quits, remove their ID
      await Constants.usersCollection.doc(host.host.id).update({
        Constants.hostingDoc: FieldValue.arrayRemove([host.user.id])
      });

      if (context.mounted) {
        GoRouter.of(context).pop();
      }
    }
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
