import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../models/objects/home.dart';
import '../../../../models/data/user_manager.dart';

class HomeButton extends StatefulWidget {
  const HomeButton({
    super.key,
  });

  @override
  State<HomeButton> createState() => _HomeButtonState();
}

class _HomeButtonState extends State<HomeButton> {
  static const double _size = 20;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomLeft,
      margin: const EdgeInsets.only(bottom: 90, left: 15),
      child: Container(
        width: _size + 25,
        height: _size + 25,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.black, blurRadius: 0.25, offset: Offset(0.5, 1))
          ],
          color: Colors.white,
        ),
        child: IconButton(
          onPressed: () async {
            Home home = await UserManager.userHome();
            if (context.mounted) {
              GoRouter.of(context).push('/home', extra: home);
            }
          },
          icon: const Icon(
            Icons.home_rounded,
            color: Colors.black,
            size: _size,
          ),
        ),
      ),
    );
  }
}
