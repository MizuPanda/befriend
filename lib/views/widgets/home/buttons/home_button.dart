import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../models/objects/home.dart';
import '../../../../models/data/user_manager.dart';
import '../../../../utilities/constants.dart';

class HomeButton extends StatelessWidget {
  const HomeButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return Container(
      alignment: Alignment.bottomLeft,
      margin: EdgeInsets.only(
          bottom: Constants.homeButtonBottomPaddingMultiplier * height,
          left: width * Constants.homeHorizontalPaddingMultiplier),
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
