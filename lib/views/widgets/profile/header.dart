import 'package:flutter/material.dart';

import '../../../models/bubble.dart';
import '../users/profile_photo.dart';
import 'notification_button.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.user,
  });

  final Bubble user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Stack(
          children: [
            Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black,
                    width: 1.0,
                  ),
                ),
                child: ProfilePhoto(
                  radius: 50,
                  user: user,
                )),
            if (user.main())
              Container(
                alignment: Alignment.topRight,
                width: 140,
                height: 100,
                child: IconButton(
                  onPressed: user.main()
                      ? () {
                          //IMPLEMENT CAMERA
                        }
                      : null,
                  icon: const Icon(
                    Icons.mode_edit_outline_outlined,
                    size: 30,
                    color: Colors.black,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.name,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '@${user.username}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        if (!user.main()) const Spacer(),
        if (!user.main())
          Container(
              height: 75,
              alignment: Alignment.topCenter,
              child: const NotificationButton()),
      ],
    );
  }
}
