import 'package:befriend/models/data/user_manager.dart';
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

  Future<void> loadFriendsAsync() async {
    try {
      if (!home.user.friendshipsLoaded) {
        final List<dynamic> randomFriendsIDS = home.user.nonLoadedFriends().take(Constants.friendsLimit).toList();

        randomFriendsIDS.shuffle();

        final List<dynamic> nonLoadedMainFriendIDS = [];
        if (!home.user.main()) {
          final Bubble mainUser = await UserManager.getInstance();
          nonLoadedMainFriendIDS.addAll(mainUser.nonLoadedFriends());
          debugPrint(
              '(HomeProvider) non loaded friends: $nonLoadedMainFriendIDS');
        }

        for (String friendID in randomFriendsIDS) {
          Friendship friend =
              await DataQuery.getFriendship(home.user.id, friendID);
          debugPrint(
              '(HomeProvider) Adding ${friend.friendUsername()} to home');

          home.user.friendships.add(friend);
          home.addFriendToHome(friend);

          // Trigger haptic feedback
          HapticFeedback.mediumImpact();
          home.setPosToMid();

          // If this is a friend of the connected user that was not loaded yet.
          if (nonLoadedMainFriendIDS.contains(friendID) && !home.user.main()) {
            final Friendship friendship =
                await DataQuery.getFriendshipFromBubble(friend.friend);

            UserManager.addFriendToMain(friendship);
            debugPrint(
                '(HomeProvider) Adding friend ${friendship.friendUsername()} to main user');
          }
          notifyListeners();
        }

        home.user.friendshipsLoaded = true;
      }
    } catch (e) {
      debugPrint('(HomeProvider) Error loading friends asynchronously: $e');
    }
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
      screenClass: 'Home',
      screenName: 'Home Page',
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

  void centerToMiddle() {
    _animationController.reset();
    _animationCenter = Matrix4Tween(
      begin: home.transformationController?.value,
      end: home.middlePos(),
    ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    _animationCenter!.addListener(_onAnimateReset);
    _animationController.forward();
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

  void goToSettings(BuildContext context) {
    GoRouter.of(context).push(Constants.settingsAddress);
  }
}
