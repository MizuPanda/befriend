import 'package:befriend/models/data/data_query.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:showcaseview/showcaseview.dart';

import '../models/objects/friendship.dart';
import '../models/objects/home.dart';
import '../utilities/constants.dart';

class HomeProvider extends ChangeNotifier {
  final TransformationController _transformationController =
      TransformationController();
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

  /// Tap on Befriend*
  final GlobalKey _five = GlobalKey();

  GlobalKey get one => _one;
  GlobalKey get two => _two;
  GlobalKey get three => _three;
  GlobalKey get four => _four;
  GlobalKey get five => _five;

  Home home;

  double get viewerSize => home.viewerSize;

  void initShowcase(BuildContext context) {
    if (home.user.friendshipsLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) =>
          ShowCaseWidget.of(context)
              .startShowCase([_one, _two, _three, _four, _five]));
    }
  }

  void _onAnimateReset() {
    _transformationController.value = _animationCenter!.value;
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

  TransformationController get transformationController =>
      _transformationController;

  Animation<Matrix4>? get animation => _animationCenter;

  void notify() {
    notifyListeners();
  }

  Future<List<Friendship>> loadFriendships() async {
    debugPrint('(HomeProvider): loadFriendships()');
    if (!home.user.friendshipsLoaded) {
      debugPrint('(HomeProvider): Starting friendships...');
      try {
        home.user.friendships =
            await DataQuery.friendList(home.user.id, home.user.friendIDs);
        home.user.friendshipsLoaded = true;
        home.initializePositions();
        _transformationController.value = home.middlePos();
        debugPrint('(HomeProvider): Friendships loaded successfully.');
      } catch (e) {
        debugPrint('(HomeProvider): Error loading friendships: $e');
        // Optionally, handle error for user feedback
      }
    }

    return home.user.friendships;
  }

  HomeProvider._({
    required this.home,
  });

  factory HomeProvider.init(TickerProvider vsync, {required Home home}) {
    HomeProvider homeProvider = HomeProvider._(home: home);

    // Initializing controller
    homeProvider._animationController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 300),
    );

    if (home.user.friendshipsLoaded) {
      home.initializePositions();
    }

    homeProvider._transformationController.value = home.middlePos();

    return homeProvider;
  }

  void doDispose() {
    _transformationController.dispose();
    _animationController.dispose();
  }

  void centerToMiddle() {
    _animationController.reset();
    _animationCenter = Matrix4Tween(
      begin: _transformationController.value,
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
      begin: _transformationController.value,
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
