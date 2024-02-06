import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../models/objects/home.dart';
import '../../../../models/data/user_manager.dart';
import '../../../../utilities/constants.dart';

class HomeButton extends StatefulWidget {
  const HomeButton({
    super.key,
  });

  @override
  State<HomeButton> createState() => _HomeButtonState();
}

class _HomeButtonState extends State<HomeButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomLeft,
      margin: const EdgeInsets.only(
          bottom: 90, left: Constants.homeHorizontalPadding),
      child: Container(
        width: Constants.homeButtonSize + Constants.homeButtonAddSize,
        height: Constants.homeButtonSize + Constants.homeButtonAddSize,
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
              GoRouter.of(context).push(Constants.homepageAddress, extra: home);
            }
          },
          icon: const Icon(
            Icons.home_rounded,
            color: Colors.black,
            size: Constants.homeButtonSize,
          ),
        ),
      ),
    );
  }
}
