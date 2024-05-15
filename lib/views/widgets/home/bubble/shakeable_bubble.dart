import 'package:befriend/models/data/user_manager.dart';
import 'package:befriend/providers/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../models/objects/bubble.dart';
import '../../../../models/objects/home.dart';
import '../../../../models/objects/profile.dart';
import '../../../../utilities/constants.dart';
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
    setState(() {});
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
    return Consumer<HomeProvider>(
        builder: (BuildContext context, HomeProvider provider, Widget? child) {
      return GestureDetector(
        onLongPress: () {
          if (widget.specificHome.isFriendToUser()) {
            setState(() {
              _isPressed = true;
            });
            _startShakeAnimation();
            HapticFeedback
                .selectionClick(); // Optionally provide haptic feedback
            Future.delayed(const Duration(milliseconds: 275), () {
              if (_isPressed) {
                GoRouter.of(context).push(Constants.homepageAddress,
                    extra: widget.specificHome);
                _animationController.reset();
              }
            });
          }
        },
        onTap: () async {
          if (widget.specificHome.isFriendToUser()) {
            Bubble connectedUser;
            if (widget.specificHome.connectedHome) {
              connectedUser = widget.specificHome.user;
            } else {
              connectedUser = await UserManager.getInstance();
            }
            if (context.mounted) {
              GoRouter.of(context).push(
                Constants.profileAddress,
                extra: Profile(
                    user: widget.specificHome.user,
                    currentUser: connectedUser,
                    notifyParent: provider.notify,
                    friendship: widget.specificHome.friendship),
              );
            }
          }

          debugPrint(
              '(ShakeableBubble): ${widget.specificHome.user.username} Tapped');
        },
        onLongPressEnd: (LongPressEndDetails details) {
          setState(() {
            _isPressed = false;
          });
        },
        child: SizedBox(
          width: widget.specificHome.user.size,
          height: widget.specificHome.user.bubbleHeight(),
          child: AnimatedBuilder(
              animation: _animation,
              builder: (BuildContext context, Widget? child) {
                return Transform.rotate(
                  angle: _isPressed ? _animation.value : 0,
                  child: BubbleWidget(specificHome: widget.specificHome),
                );
              }),
        ),
      );
    });
  }
}
