import 'dart:io';

import 'package:befriend/models/data/picture_manager.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/data/picture_query.dart';
import '../models/data/user_manager.dart';
import '../models/objects/home.dart';
import '../utilities/constants.dart';

class PictureSignProvider extends ChangeNotifier {
  static const Color foregroundColor = Color(0xFF1F465E);

  String? _imagePath;

  bool imageNull() {
    return _imagePath == null;
  }

  ImageProvider image() {
    return Image.file(File(_imagePath!)).image;
  }

  Future<void> retrieveImage(BuildContext context) async {
    await PictureManager.takeProfilePicture(
      context,
      (String? url) {
        _imagePath = url;
      },
    );
    notifyListeners();
  }

  Future<void> continueHome(BuildContext context) async {
    await PictureQuery.uploadAvatar(File(_imagePath!));
    if (context.mounted) {
      skipHome(context);
    }
  }

  Future<void> skipHome(BuildContext context) async {
    Home user = await UserManager.userHome();
    if (context.mounted) {
      GoRouter.of(context).push(Constants.homepageAddress, extra: user);
    }
  }
}
