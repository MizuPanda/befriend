import 'dart:io';

import 'package:befriend/models/data/picture_query.dart';
import 'package:befriend/models/data/user_manager.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../providers/picture_provider.dart';

class PictureManager {
  static Future<ImageProvider> changeMainPicture(String path) async {
    await PictureQuery.uploadAvatar(File(path));
    return await UserManager.refreshAvatar();
  }
  static Image image(String? imagePath) {
    return Image.file(File(imagePath!));
  }

  static Future<void> showChoiceDialog(BuildContext context, Function(CroppedFile?) function) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Make a choice!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                GestureDetector(
                  child: const Text("Gallery"),
                  onTap: () async {
                    await _pickImage(ImageSource.gallery, context, function);
                  },
                ),
                const Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: const Text("Camera"),
                  onTap: () async {
                    await _pickImage(ImageSource.camera, context, function);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<void> _pickImage(ImageSource source, BuildContext context, Function(CroppedFile?) function) async {
    final pickedImage =
    await ImagePicker().pickImage(source: source, imageQuality: 10);

    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedImage!.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: PictureSignProvider.foregroundColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ],
    );

    await function(croppedFile);
  }
}