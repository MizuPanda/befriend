import 'package:befriend/models/authentication/authentication.dart';
import 'package:befriend/views/widgets/profile/profile_pictures.dart';
import 'package:flutter/material.dart';

class ArchiveSettingsWidget extends StatelessWidget {
  const ArchiveSettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Archives",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ProfilePictures(
        userID: AuthenticationManager.id(),
        showArchived: true,
      ),
    );
  }
}
