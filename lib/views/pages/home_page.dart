import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/bubble.dart';
import '../../models/bubble_user.dart';
import '../widgets/befriend_widget.dart';
import '../widgets/bubble_widget.dart';
import '../widgets/home/search_button.dart';
import '../widgets/home/picture_button.dart';
import '../widgets/home/settings_button.dart';

class HomePage extends StatefulWidget {
  final Bubble bubble;

  const HomePage({super.key, required this.bubble});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin {
  late final List<Friendship> _friendships;
  Offset _position = Offset.zero;

  AnimationType _animationType = AnimationType.reset;
  Offset? _friendPosition;

  late AnimationController _animationController;
  late AnimationController _offsetController;

  late CurvedAnimation _animation;
  late Animation<Offset> _offsetAnimation;

  void _initializePositions() {
    Bubble main = widget.bubble;

    for (Friendship friendship in _friendships) {
      Bubble b = friendship.friendBubble;
      Random rand = Random(); //Distance = 10
      b.x = rand.nextDouble() * friendship.distance(); // x=6
      b.y = sqrt(
          pow(friendship.distance(), 2) - pow(b.x, 2)); //100 - 36 = 64, y = 8

      b.x += (main.size + b.size / 2) / 2 + BubbleWidget.textHeight;
      b.y += (main.size + b.size / 2) / 2 + BubbleWidget.textHeight;

      if (rand.nextBool()) {
        b.x *= -1;
      }
      if (rand.nextBool()) {
        b.y *= -1;
      }
    }
    _avoidOverlapping();
  }

  void _avoidOverlapping() {
    bool overlapping = true;

    _friendships.sort((a, b) => a.distance().compareTo(b.distance()));
    while (overlapping) {
      overlapping = false;
      for (var i = 0; i < _friendships.length; i++) {
        final bubble = _friendships[i].friendBubble;

        for (var j = i + 1; j < _friendships.length; j++) {
          final otherBubble = _friendships[j].friendBubble;
          final dx = otherBubble.x - bubble.x;
          final dy = otherBubble.y - bubble.y;
          final distance = sqrt(dx * dx + dy * dy);
          final force = bubble.size * otherBubble.size / (distance * distance);

          if (distance < bubble.size + otherBubble.size) {
            overlapping = true;

            otherBubble.x += (dx / distance) * force;
            otherBubble.y += (dy / distance) * force;
          }
        }
      }
    }
  }

  void _animateToFriend(Offset friendPosition, AnimationType animationType) {
      _animationType = animationType;
      _friendPosition = friendPosition*-1;

      _offsetAnimation = Tween<Offset>(
        begin: _position,
        end: _friendPosition!,
      ).animate(CurvedAnimation(parent: _offsetController, curve: Curves.easeInOut));

      _offsetController.reset();
      _offsetController.forward();

  }

  @override
  void initState() {
    _friendships = widget.bubble.friendships;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.addListener(() {
      if (_animationController.isCompleted) {
        _position = Offset.zero;
        _animationController.reset();
      }
    });

    _offsetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _offsetController.addListener(() {
      if (_offsetController.isCompleted) {
          _position = _friendPosition!;
          _animationType = AnimationType.reset;
      }
    });

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _offsetAnimation = Tween<Offset>(
      begin: _position,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _offsetController, curve: Curves.easeInOut));
    _initializePositions();

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onPanUpdate: (DragUpdateDetails details) {
              setState(() {
                _position += details.delta;
              });
            },
            onDoubleTap: () {
              _animationController.reset();
              _animationController.forward();
            },
            child: Container(
              color: Colors.white,
              width: double.infinity,
              height: double.infinity,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (BuildContext context, Widget? child) {
                  return AnimatedBuilder(
                    animation: _offsetAnimation,
                    builder: (BuildContext context, Widget? child) {
                      return Transform.translate( //Position doesn't correlate on screen
                        offset: _animationType == AnimationType.reset? _position* (1 - _animation.value) : _offsetAnimation.value,
                        child: Stack(
                          children: [
                            BubbleWidget(
                              user: BubbleUser(
                                  main: true, mainBubble: widget.bubble),
                            ),
                            for (Friendship friendship in _friendships)
                              Transform.translate(
                                offset: Offset(friendship.friendBubble.x,
                                    friendship.friendBubble.y),
                                child: BubbleWidget(
                                    user: BubbleUser(
                                        main: false, friendship: friendship)),
                              )
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          const BefriendWidget(),
          const SettingsButton(),
          SearchButton(bubble: widget.bubble, animate: _animateToFriend,),
          const PictureButton(),
        ],
      ),
    );
  }
}

enum AnimationType {
  reset,
  friend
}