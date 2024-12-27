import 'package:befriend/views/widgets/home/buttons/round_button.dart';
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
    return RoundButton(
      onPressed: () async {
        Home home = await UserManager.userHome();
        if (context.mounted) {
          GoRouter.of(context).go(Constants.homepageAddress, extra: home);
        }
      },
      data: Icons.home_rounded,
    );
  }
}
