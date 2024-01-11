import 'package:befriend/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/objects/profile.dart';
import '../users/profile_photo.dart';
import 'notification_button.dart';

class ProfileHeader extends StatefulWidget {
  const ProfileHeader({
    super.key,
    required this.profile,
  });

  final Profile profile;

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProfileProvider>(
        create: (_) => ProfileProvider(),
        builder: (BuildContext context, Widget? child) {
          return Row(
            children: [
              Consumer<ProfileProvider>(builder: (BuildContext context,
                  ProfileProvider provider, Widget? child) {
                return Stack(
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
                          user: widget.profile.user,
                        )),
                    if (widget.profile.user.main())
                      Container(
                        alignment: Alignment.topRight,
                        width: 140,
                        height: 100,
                        child: IconButton(
                          onPressed: widget.profile.user.main()
                              ? () async {
                                  await provider.changeProfilePicture(
                                      context,
                                      widget.profile.user,
                                      widget.profile.notifyParent);
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
                );
              }),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.profile.user.name,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '@${widget.profile.user.username}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              if (!widget.profile.user.main()) const Spacer(),
              if (!widget.profile.user.main())
                Container(
                    height: 75,
                    alignment: Alignment.topCenter,
                    child: const NotificationButton()),
            ],
          );
        });
  }
}
