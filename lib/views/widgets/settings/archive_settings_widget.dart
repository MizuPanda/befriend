import 'package:befriend/views/widgets/profile/profile_pictures.dart';
import 'package:flutter/material.dart';

import '../../../models/authentication/authentication.dart';
import '../../../utilities/app_localizations.dart';

class ArchiveSettingsWidget extends StatelessWidget {
  const ArchiveSettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.translate(context,
              key: 'asw_archives', defaultString: "Archives"),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ProfilePictures(
        profileUsername: "",
        userID: AuthenticationManager.id(),
        showArchived: true,
        showOnlyMe: false,
        isLocked: false,
      ),
    );
  }
}
