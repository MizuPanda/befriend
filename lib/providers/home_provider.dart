import 'package:befriend/models/data/data_query.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../models/objects/friendship.dart';
import '../models/objects/home.dart';
import '../utilities/constants.dart';

class HomeProvider extends ChangeNotifier {
  final TransformationController _transformationController =
      TransformationController();
  late final AnimationController _animationController;
  Animation<Matrix4>? _animationCenter;

  Home home;

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
      home.user.friendships =
          await DataQuery.friendList(home.user.id, home.user.friendIDs);
      home.user.friendshipsLoaded = true;
      home.initializePositions();
    }

    return home.user.friendships;
  }

  HomeProvider({required this.home});

  void init(TickerProvider vsync) async {
    // Initializing controller
    _animationController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 300),
    );

    _transformationController.value = _middlePos();

    if (home.user.friendshipsLoaded) {
      home.initializePositions();
    }

    notifyListeners();
  }

  Matrix4 _middlePos() {
    // Calculate the initial transformation to center the content

    return Matrix4.identity()
      ..translate(-Constants.viewerSize / 2, -Constants.viewerSize / 2);
  }

  void doDispose() {
    _transformationController.dispose();
    _animationController.dispose();
  }

  void centerToMiddle() {
    _animationController.reset();
    _animationCenter = Matrix4Tween(
      begin: _transformationController.value,
      end: _middlePos(),
    ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    _animationCenter!.addListener(_onAnimateReset);
    _animationController.forward();
  }

  void animateToFriend(BuildContext context,
      {required double dx, required double dy}) {
    double width = dx + Constants.viewerSize / 2;
    double height = dy + Constants.viewerSize / 2;

    Matrix4 friendPos = Matrix4.identity()..translate(-width, -height);
    debugPrint('(HomeProvider): FriendPos = $friendPos');

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
