import 'package:befriend/views/pages/profile_page.dart';
import 'package:befriend/views/widgets/users/profile_photo.dart';
import 'package:befriend/views/widgets/users/username_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/bubble.dart';
import '../pages/home_page.dart';
import 'bubble_progress_indicator.dart';

class BubbleWidget extends StatelessWidget {
  final Bubble user;
  final bool connectedHome;
  static const double strokeWidth = 10/3;
  static const double textHeight = 25;
  static const double levelHeight = 25;
  const BubbleWidget(
      {Key? key, required this.user, required this.connectedHome})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ProfilePage(user: user)));
      },
      child: Center(
        child: SizedBox(
          height: user.size + textHeight + 2,
          child: Builder(builder: (context) {
            if (!user.main()) {
              Friendship friendship = user.friendship()!;
              return Badge(
                label: Text(
                  friendship.newPics.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                largeSize: 26,
                offset: const Offset(0, 0),
                padding: const EdgeInsets.only(left: 8, right: 7),
                isLabelVisible: friendship.newPics > 0,
                child: Builder(builder: (context) {
                  if (connectedHome) {
                    return Stack(
                      children: [
                        Column(
                          children: [
                            Stack(children: [
                              BubbleContainer(user: user),
                              BubbleProgressIndicator(friendship: friendship),
                              BubbleGradientIndicator(friendship: friendship),
                            ]),
                            UsernameText(user: user),
                          ],
                        ),
                        Container(
                          width: user.size,
                          padding: EdgeInsets.only(
                              bottom: textHeight - levelHeight + 30 / 2,
                              left: user.size / 2),
                          alignment: Alignment.bottomCenter,
                          child: Text(
                            friendship.level.toString(),
                            style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: levelHeight /
                                  (1 + user.size / (user.size * 7)),
                              shadows: const [
                                Shadow(
                                  offset: Offset.zero,
                                  blurRadius: 15.0,
                                  color: Colors.black,
                                ),
                              ],
                            )),
                          ),
                        )
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        BubbleContainer(user: user),
                        UsernameText(user: user),
                      ],
                    );
                  }
                }),
              );
            } else {
              return SizedBox(
                height: user.size + textHeight,
                child: Column(
                  children: [
                    BubbleContainer(user: user),
                    UsernameText(
                      user: user,
                    ),
                  ],
                ),
              );
            }
          }),
        ),
      ),
    );
  }
}

class BubbleContainer extends StatelessWidget {
  const BubbleContainer({
    super.key,
    required this.user,
  });

  final Bubble user;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.black,
            width: 1.0,
          ),
        ),
        child: ProfilePhoto(user: user)
    );
  }
}

class ShakeableBubble extends StatefulWidget {
  const ShakeableBubble(
      {super.key, required this.user, required this.connectedHome});
  final Bubble user;
  final bool connectedHome;

  @override
  State<ShakeableBubble> createState() => _ShakeableBubbleState();
}

class _ShakeableBubbleState extends State<ShakeableBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isPressed = false;
  final double _animationRange = 0.08;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController.reverse();
        }
      });
    _animation =
        Tween<double>(begin: -_animationRange, end: _animationRange).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startShakeAnimation() {
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        setState(() {
          _isPressed = true;
        });
        _startShakeAnimation();
        HapticFeedback.selectionClick(); // Optionally provide haptic feedback
        Future.delayed(const Duration(milliseconds: 275), () {
          if (_isPressed) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HomePage(
                          user: widget.user,
                      connectedHome: widget.user.main(),
                        )));
            _animationController.reset();
          }
        });
      },
      onLongPressEnd: (LongPressEndDetails details) {
        setState(() {
          _isPressed = false;
        });
      },
      child: AnimatedBuilder(
          animation: _animation,
          builder: (BuildContext context, Widget? child) {
            return Transform.rotate(
              angle: _isPressed ? _animation.value : 0,
              child: BubbleWidget(
                user: widget.user,
                connectedHome: widget.connectedHome,
              ),
            );
          }),
    );
  }
}
