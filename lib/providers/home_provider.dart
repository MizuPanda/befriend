import 'package:befriend/models/data/data_manager.dart';
import 'package:befriend/models/data/user_manager.dart';
import 'package:befriend/models/objects/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:showcaseview/showcaseview.dart';

import '../models/data/data_query.dart';
import '../models/objects/bubble.dart';
import '../models/objects/friendship.dart';
import '../models/objects/home.dart';
import '../models/services/notification_service.dart';
import '../utilities/constants.dart';

class HomeProvider extends ChangeNotifier {
  late final AnimationController _animationController;
  Animation<Matrix4>? _animationCenter;
  final TextEditingController _searchEditingController =
      TextEditingController();

  TextEditingController get searchEditingController => _searchEditingController;

  /// Info
  final GlobalKey _one = GlobalKey();

  /// Tap profile
  final GlobalKey _two = GlobalKey();

  /// Hold Character
  final GlobalKey _three = GlobalKey();

  /// Swipe Picture Button*
  final GlobalKey _four = GlobalKey();

  GlobalKey get one => _one;
  GlobalKey get two => _two;
  GlobalKey get three => _three;
  GlobalKey get four => _four;

  Home home;

  double get viewerSize => home.viewerSize;

  TransformationController? get transformationController =>
      home.transformationController;

  void initShowcase(BuildContext context) {
    if (home.connectedHome) {
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => ShowCaseWidget.of(context).startShowCase([
                _one,
                _two,
                _three,
                _four,
              ]));
    }
  }

  void disposeSearch() {
    _searchEditingController.dispose();
  }

  void clearSearch() {
    _searchEditingController.clear();
    notifyListeners();
  }

  Future<void> search(String username, BuildContext context) async {
    // Check if the username is present in the loaded friendships.
    //    If yes -> animateToFriend
    //    If no  -> get the user data from Firestore. If does not exist or is part of either blocked, don't do nothing
    //       Check if searchId is present in friendsIds
    //          If yes -> Add the friend to the profile and animateToFriend
    username = username.trim();

    try {
      final Iterable<String> loadedUsernames =
          home.user.friendships.map((friendship) => friendship.friend.username);

      if (loadedUsernames.contains(username)) {
        debugPrint('(HomeProvider) $username is loaded');
        final Friendship friendship = home.user.friendships
            .firstWhere((f) => f.friend.username == username);
        final Bubble searchedBubble = friendship.friend;
        animateToFriend(context, dx: searchedBubble.x, dy: searchedBubble.y);
      } else {
        final QuerySnapshot result = await Constants.usersCollection
            .where(Constants.usernameDoc, isEqualTo: username)
            .limit(1)
            .get();

        final List<DocumentSnapshot> documents = result.docs;

        if (documents.isNotEmpty) {
          final DocumentSnapshot snapshot = documents.first;

          final ImageProvider avatar = await DataManager.getAvatar(snapshot);
          final Bubble searchedBubble =
              Bubble.fromDocs(documents.first, avatar);

          final Bubble mainUser = await UserManager.getInstance();

          if (mainUser.friendIDs.contains(searchedBubble.id)) {
            debugPrint('(HomeProvider) $username is non loaded friend');

            final Friendship friendship =
                await DataQuery.getFriendshipFromBubble(searchedBubble);

            UserManager.addFriendToList(friendship);
            UserManager.notify();
            if (context.mounted) {
              animateToFriend(context,
                  dx: searchedBubble.x, dy: searchedBubble.y);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('(HomeProvider) Error searching for $username: $e');
    }
  }

  Future<void> goToFriendProfile(BuildContext context, Profile profile) async {
    await GoRouter.of(context).push(
      Constants.profileAddress,
      extra: profile,
    );
  }

  Future<void> loadFriendsAsync() async {
    try {
      if (!home.user.friendshipsLoaded) {
        final List<dynamic> randomFriendsIDS =
            home.user.nonLoadedFriends().take(Constants.friendsLimit).toList();

        final List<dynamic> nonLoadedMainFriendIDS = [];
        if (!home.user.main()) {
          final Bubble mainUser = await UserManager.getInstance();
          nonLoadedMainFriendIDS.addAll(mainUser.nonLoadedFriends());
          debugPrint(
              '(HomeProvider) non loaded friends: $nonLoadedMainFriendIDS');
        }

        final Friendship? bestFriend = await _getBestFriend();

        if (bestFriend != null) {
          _loadFriend(bestFriend);

          randomFriendsIDS.remove(bestFriend.friend.id);
          notifyListeners();
        }

        for (String friendID in randomFriendsIDS) {
          Friendship friend =
              await DataQuery.getFriendship(home.user.id, friendID);

          _loadFriend(friend);

          // If this is a friend of the connected user that was not loaded yet.
          // --> Add it to main.
          if (nonLoadedMainFriendIDS.contains(friendID) && !home.user.main()) {
            final Friendship friendship =
                await DataQuery.getFriendshipFromBubble(friend.friend);

            UserManager.addFriendToMain(friendship);
            debugPrint(
                '(HomeProvider) Adding friend ${friendship.friend.username} to main user');
          }
          notifyListeners();
        }

        home.user.friendshipsLoaded = true;
      }
    } catch (e) {
      debugPrint('(HomeProvider) Error loading friends asynchronously: $e');
    }
  }

  Future<Friendship?> _getBestFriend() async {
    try {
      // Get best friend.
      // load friend into friendships and then set isBestFriend to true
      // Return friend id
      Query query = Constants.friendshipsCollection
          .where(Filter.or(Filter(Constants.user1Doc, isEqualTo: home.user.id),
              Filter(Constants.user2Doc, isEqualTo: home.user.id)))
          .orderBy(Constants.levelDoc, descending: true)
          .orderBy(Constants.progressDoc, descending: true)
          .limit(1);

      QuerySnapshot snapshot = await query.get();

      if (snapshot.size == 1) {
        final DocumentSnapshot doc = snapshot.docs.first;
        final String user1 = DataManager.getString(doc, Constants.user1Doc);
        final String user2 = DataManager.getString(doc, Constants.user2Doc);

        final String friendId = user1 == home.user.id ? user2 : user1;
        UserManager.setBestFriendID(friendId);

        final DocumentSnapshot bubbleDoc =
            await DataManager.getData(id: friendId);
        final ImageProvider avatar = await DataManager.getAvatar(bubbleDoc);

        final Bubble friendBubble = Bubble.fromDocs(bubbleDoc, avatar);
        final Friendship friendship =
            Friendship.fromDocs(home.user.id, friendBubble, doc);

        friendship.isBestFriend = true;
        return friendship;
      }

      return null;
    } catch (e) {
      debugPrint('(HomeProvider) Error in fetching best friend: $e');
      return null;
    }
  }

  Future<void> _loadFriend(Friendship friend) async {
    debugPrint('(HomeProvider) Adding ${friend.friend.username} to home');

    home.user.friendships.add(friend);
    home.addFriendToHome(friend);

    // Trigger haptic feedback
    HapticFeedback.mediumImpact();
    home.setPosToMid();
  }

  void _onAnimateReset() {
    home.transformationController?.value = _animationCenter!.value;

    if (!_animationController.isAnimating) {
      _animationCenter!.removeListener(_onAnimateReset);
      _animationCenter = null;
      _animationController.reset();
    }
  }

// Stop a running reset to home transform animation.
  void _animateResetStop() {
    _animationController.stop();
    _animationCenter?.removeListener(_onAnimateReset);
    _animationCenter = null;
    _animationController.reset();
  }

  void onInteractionStart(ScaleStartDetails details) {
    // If the user tries to cause a transformation while the reset animation is
    // running, cancel the reset animation.
    if (_animationController.status == AnimationStatus.forward) {
      _animateResetStop();
    }
  }

  Animation<Matrix4>? get animation => _animationCenter;

  void notify() {
    debugPrint('(HomeProvider) Notifying home page');
    notifyListeners();
  }

  HomeProvider._({
    required this.home,
  });

  factory HomeProvider.init(TickerProvider vsync, {required Home home}) {
    HomeProvider homeProvider = HomeProvider._(home: home);

    home.transformationController = TransformationController();

    // Initializing controller
    homeProvider._animationController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 300),
    );

    if (home.user.friendshipsLoaded) {
      home.initializePositions();
    }

    home.setPosToMid();

    return homeProvider;
  }

  Future<void> initServices(
    GlobalKey<ScaffoldState> scaffoldKey,
  ) async {
    NotificationService.initNotifications(scaffoldKey, notify);
    MobileAds.instance.initialize();
  }

  Future<void> logAnalytics() async {
    await FirebaseAnalytics.instance.logScreenView(
      screenClass: 'home',
      screenName: 'home_page',
    );
  }

  Future<void> initLanguage(BuildContext context) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        if (home.user.main()) {
          final String languageCode =
              Localizations.localeOf(context).languageCode;
          if (home.user.languageCode != languageCode) {
            debugPrint(
                '(HomeProvider) Updating language from ${home.user.languageCode} to $languageCode');
            await DataQuery.updateDocument(Constants.languageDoc, languageCode);
            home.user.languageCode = languageCode;
            UserManager.setLanguageCode(languageCode);
          }
        }
      } catch (e) {
        debugPrint("(HomeProvider) Error updating language= $e");
      }
    });
  }

  void initNotify() {
    if (home.user.main()) {
      UserManager.setNotify(notify);
    }
  }

  void doDispose() {
    home.transformationController?.dispose();
    home.transformationController = null;
    _animationController.dispose();
  }

  void centerToMiddle(BuildContext context) {
    _animationController.reset();
    _animationCenter = Matrix4Tween(
      begin: home.transformationController?.value,
      end: home.middlePos(),
    ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    _animationCenter!.addListener(_onAnimateReset);
    _animationController.forward();

    HapticFeedback.mediumImpact();
  }

  void animateToFriend(BuildContext context,
      {required double dx, required double dy}) {
    double width = dx + home.viewerSize / 4;
    double height = dy + home.viewerSize / 4;

    Matrix4 friendPos = Matrix4.identity()..translate(-width, -height);

    _animationController.reset();
    _animationCenter = Matrix4Tween(
      begin: home.transformationController?.value,
      end: friendPos,
    ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    _animationCenter!.addListener(_onAnimateReset);
    _animationController.forward();
  }

  void pushToSettings(BuildContext context) {
    GoRouter.of(context).push(Constants.settingsAddress);
  }

  void pushToWideSearch(BuildContext context) {
    GoRouter.of(context).push(Constants.wideSearchAddress);
  }
}
