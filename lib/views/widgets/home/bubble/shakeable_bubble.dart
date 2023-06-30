import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../models/home.dart';
import 'bubble_widget.dart';

class ShakeableBubble extends StatefulWidget {
  const ShakeableBubble({
    super.key,
    required this.specificHome,
  });

  final Home specificHome;

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
    super.initState();
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
            GoRouter.of(context).push('/homepage', extra: widget.specificHome);
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
              child: BubbleWidget(specificHome: widget.specificHome),
            );
          }),
    );
  }
}
