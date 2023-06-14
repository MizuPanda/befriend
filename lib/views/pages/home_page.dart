import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/bubble.dart';
import '../widgets/bubble_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final Bubble main = Bubble(name: 'You', distance: 0, size: 120);

  late final List<Bubble> bubbles;
  Offset _position = Offset.zero;

  late AnimationController _animationController;
  late CurvedAnimation _animation;

  Color _randColor() {
    Random r = Random();
    int max = 255;
    return Color.fromRGBO(r.nextInt(max), r.nextInt(max), r.nextInt(max), 1);
  }

  void _avoidOverlapping() {
    bool overlapping = true;

    bubbles.sort((a, b) => a.distance.compareTo(b.distance));
    while (overlapping) {
      overlapping = false;
      for (var i = 0; i < bubbles.length; i++) {
        final bubble = bubbles[i];

        for (var j = i + 1; j < bubbles.length; j++) {
          final otherBubble = bubbles[j];
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

  @override
  void initState() {
    bubbles = [
      Bubble(
        name: 'Friend 1',
        distance: 40,
        progress: 0.6,
        size: 60,
        main: main,
        color: _randColor(),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.red, Colors.deepOrange],
        ),
      ),
      Bubble(
        name: 'Friend 2',
        distance: 30,
        progress: 0.2,
        size: 80,
        main: main,
        color: _randColor(),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.pink, Colors.purple],
        ),
      ),
      Bubble(
        name: 'Friend 3',
        distance: 50,
        progress: 0.1,
        size: 100,
        main: main,
        color: _randColor(),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.lightBlueAccent, Colors.blueAccent],
        ),
      ),
      Bubble(
        name: 'Friend 4',
        distance: 75,
        progress: 0.9,
        size: 75,
        main: main,
        color: _randColor(),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.lightGreenAccent, Colors.greenAccent],
        ),
      )
    ];
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
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _avoidOverlapping();
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
                //debugPrint('position: $_position');
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
                  return Transform.translate(
                    offset: _position * (1 - _animation.value),
                    child: Stack(
                      children: [
                        BubbleWidget(
                          bubble: main,
                          color: Colors.red,
                        ),
                        for (Bubble bubble in bubbles)
                          Transform.translate(
                            offset: Offset(bubble.x, bubble.y),
                            child: BubbleWidget(
                              bubble: bubble,
                            ),
                          )
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Text(
                'Befriend',
                style: TextStyle(
                    fontFamily: 'ComingSoon',
                    fontWeight: FontWeight.bold,
                    fontSize: 35),
              ),
            ),
          ),
          SafeArea(
              child: Align(
            alignment: Alignment.topRight,
            child: IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.settings_rounded,
                  size: 35,
                  color: Colors.blueGrey,
                )),
          ))
        ],
      ),
    );
  }
}
