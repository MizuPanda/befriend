import 'dart:math';

import 'package:befriend/models/data/data_manager.dart';
import 'package:befriend/models/data/data_query.dart';
import 'package:befriend/models/data/picture_query.dart';
import 'package:befriend/models/data/user_manager.dart';
import 'package:befriend/models/objects/friendship_progress.dart';
import 'package:befriend/models/services/post_service.dart';
import 'package:befriend/utilities/error_handling.dart';
import 'package:befriend/views/dialogs/session/fullscreen_image_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

import '../models/data/picture_manager.dart';
import '../models/objects/bubble.dart';
import '../models/objects/host.dart';
import '../utilities/app_localizations.dart';
import '../utilities/constants.dart';

import 'dart:io' show File, Platform;

import '../utilities/secrets.dart';

import 'package:path/path.dart' as path;

class SessionProvider extends ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  final Host host;
  final Map<String, Bubble> idToBubbleMap;
  final Map<String, double> _sliderValues = {};
  final List<String> ids;
  String? _caption;
  String? _lastCaptionSubmitted;
  final int characterLimit = 300; // Set your desired character limit
  bool _isSessionEnded = false;

  int selectedIndex = 0;

  InterstitialAd? _interstitialAd;

  final FocusNode _focusNode = FocusNode();
  final ValueNotifier<int> _charCountNotifier = ValueNotifier<int>(0);
  final ScrollController _scrollController = ScrollController();

  FocusNode get focusNode => _focusNode;
  ValueNotifier<int> get charCountNotifier => _charCountNotifier;
  ScrollController get scrollController => _scrollController;

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

  void disposeControllers() {
    _focusNode.dispose();
    _charCountNotifier.dispose();
    _scrollController.dispose();
  }

  void unfocus() async {
    _focusNode.unfocus();
    await _updateCaption();
  }

  String caption() {
    return _caption ?? '';
  }

  void onChanged(String? value) {
    _caption = value;
    _charCountNotifier.value = value?.length ?? 0;
  }

  void onSubmitted(String? value) async {
    await _updateCaption();
  }

  Future<void> _updateCaption() async {
    if (_caption != _lastCaptionSubmitted) {
      debugPrint('(SessionProvider) Updating caption to ${caption()}');
      _lastCaptionSubmitted = _caption;
      await DataQuery.updateDocument(
          Constants.captionDoc, _lastCaptionSubmitted);
    }
  }

  void _initShowcase(BuildContext context, bool showTutorial) {
    if (showTutorial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ShowCaseWidget.of(context).startShowCase(host.main()
            ? [
                _one,
                _two,
                _three,
              ]
            : [
                _two,
                _three,
              ]);
      });
    }
  }

  void showCase(
    BuildContext context,
  ) {
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
    final String adUnitId =
        /*
        Platform.isAndroid
            ? Secrets.sessionAndroidAdTile
            : Secrets.sessioniOSAdTile;
      */
        // /*
        Platform.isAndroid
            ? Constants.sessionAndroidTestAdUnit
            : Constants.sessioniOSTestAdUnit;
    //   */

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
          FirebaseAnalytics.instance.logEvent(name: 'picture_taken_with_ad');
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
      debugPrint('(SessionProvider) Processing snapshot...');

      if (_isSessionEnded) {
        return;
      }
      bool sliderValuesUpdated = false;

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
          String newCaption = docChange.doc[Constants.captionDoc];

          if (!host.main() && _caption != newCaption) {
            _caption = newCaption;
            debugPrint("(SessionProvider) Caption=$_caption");
            WidgetsBinding.instance.addPostFrameCallback((_) {
              notifyListeners();
            });
          }

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

      host.setCriticalPoints();
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();

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

    debugPrint('(SessionProvider) Finished retrieving friendshipMap');
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
      _isLoading = true;
      notifyListeners();

      List<String> sessionUsers = ids;

      host.joiners = host.joiners
          .where((element) => sessionUsers.contains(element.id))
          .toList();

      debugPrint('(SessionProvider) Publishing to $sessionUsers');

      host.calculateAllowedUsers(_sliderValues, bubble);

      List<String> usersAllowed = [];

      Iterable<String> notArchivedUsers = sessionUsers
          .map((sessionUser) => '${Constants.notArchived}$sessionUser');

      usersAllowed.addAll(notArchivedUsers);
      List<String> friendsAllowed = host.friendsAllowed().toList();
      usersAllowed.addAll(friendsAllowed);

      File file = host.tempFile();

      Map<String, String> metadata = {
        'size': _formatBytes(file.lengthSync(), 0),
        'extension': path.extension(file.path),
      };

      await PictureQuery.callPublishPicture(
        sessionUsers: sessionUsers,
        caption: caption(),
        host: host,
        userMap: idToBubbleMap
            .map((id, userBubble) => MapEntry(id, userBubble.username)),
        usersAllowed: usersAllowed,
        metadata: metadata,
        isPublic: host.isPublic(),
      );

      if (context.mounted) {
        _sendNotificationsToUser(sessionUsers, host.joiners, context);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('(SessionProvider) Error publishing picture: $e');
      _isLoading = false;
      notifyListeners();
      if (context.mounted) {
        ErrorHandling.showError(
            context,
            AppLocalizations.translate(context,
                key: 'sp_publish_error',
                defaultString: 'Error publishing picture. Please try again.'));
      }
    }
  }

  static String _formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
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

    await Constants.usersCollection.doc(host.host.id).update(
        {Constants.hostingFriendshipsDoc: {}, Constants.captionDoc: ''});
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
