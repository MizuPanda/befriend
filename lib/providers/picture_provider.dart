import 'dart:io';

import 'package:befriend/models/data/picture_manager.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';

import '../models/data/picture_query.dart';
import '../models/data/user_manager.dart';

class PictureSignProvider extends ChangeNotifier {
  static const Color foregroundColor = Color(0xFF1F465E);

  String? _imagePath;

  bool imageNull() {
    return _imagePath == null;
  }

  ImageProvider image() {
    return PictureManager.image(_imagePath).image;
  }

  Future<void> retrieveImage(BuildContext context) async {
      await PictureManager.showChoiceDialog(context, _retrievePath);
      notifyListeners();
      if (context.mounted) {
        GoRouter.of(context).pop();
      }
  }

  void _retrievePath(CroppedFile? file) async {
    _imagePath = file!.path;
  }

  Future<void> continueHome(BuildContext context) async {
    await PictureQuery.uploadAvatar(File(_imagePath!));
    if (context.mounted) {
      skipHome(context);
    }
  }

  Future<void> skipHome(BuildContext context) async {
    if (context.mounted) {
      GoRouter.of(context)
          .push('/homepage', extra: await UserManager.userHome());
    }
  }
}
