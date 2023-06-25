import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/bubble.dart';
import '../widgets/befriend_widget.dart';
import '../widgets/bubble_widget.dart';
import '../widgets/home/bubble_group.dart';
import '../widgets/home/home_button.dart';
import '../widgets/home/search_button.dart';
import '../widgets/home/picture_button.dart';
import '../widgets/home/settings_button.dart';

class HomePage extends StatefulWidget {
  final Bubble user;
  final bool connectedHome;

  const HomePage({super.key, required this.user, required this.connectedHome});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final List<Friendship> _friendships;
  Offset _position = Offset.zero;

  _AnimationType _animationType = _AnimationType.reset;
  Offset? _friendPosition;

  late AnimationController _animationController;
  late AnimationController _offsetController;

  late CurvedAnimation _animation;
  late Animation<Offset> _offsetAnimation;

  void _initializePositions() {
    Bubble main = widget.user;
    Random rand = Random();

    for (Friendship friendship in _friendships) {
      Bubble b = friendship.friendBubble;
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
          final distance = otherBubble.point().distanceTo(bubble.point());
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

  void _animateToFriend(Offset friendPosition) {
    _animationType = _AnimationType.friend;
    _friendPosition = friendPosition * -1;

    _offsetAnimation = Tween<Offset>(
      begin: _position,
      end: _friendPosition!,
    ).animate(
        CurvedAnimation(parent: _offsetController, curve: Curves.easeInOut));

    _offsetController.reset();
    _offsetController.forward();
  }

  @override
  void initState() {
    _friendships = widget.user.friendships;

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
        _animationType = _AnimationType.reset;
      }
    });

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _offsetAnimation = Tween<Offset>(
      begin: _position,
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _offsetController, curve: Curves.easeInOut));
    _initializePositions();

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _offsetController.dispose();
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
                      return Transform.translate(
                        //Position doesn't correlate on screen
                        offset: _animationType == _AnimationType.reset
                            ? _position * (1 - _animation.value)
                            : _offsetAnimation.value,
                        child: BubbleGroupWidget(
                            widget: widget, friendships: _friendships),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          const BefriendWidget(),
          const SettingsButton(),
          SearchButton(
            bubble: widget.user,
            animate: _animateToFriend,
          ),
          const PictureButton(),
          if(!widget.connectedHome)
            const HomeButton()
        ],
      ),
    );
  }
}

enum _AnimationType { reset, friend }
