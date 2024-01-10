import 'dart:io';

import 'package:befriend/models/data/picture_query.dart';
import 'package:befriend/models/data/user_manager.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../providers/picture_provider.dart';

class PictureManager {
  static Future<ImageProvider> changeMainPicture(String path) async {
    await PictureQuery.uploadAvatar(File(path));
    return await UserManager.refreshAvatar();
  }

  static Image image(String? imagePath) {
    return Image.file(File(imagePath!));
  }

  static Future<void> _askCameraPermission() async {
    bool isGranted = await Permission.camera.isGranted;
    if (!isGranted) {
      await Permission.camera
          .onDeniedCallback(() {})
          .onGrantedCallback(() {})
          .onPermanentlyDeniedCallback(() {})
          .onRestrictedCallback(() {})
          .onLimitedCallback(() {})
          .onProvisionalCallback(() {})
          .request();
    }
  }

  static Future<void> showChoiceDialog(
      BuildContext context, String? imageUrl) async {
    await _askCameraPermission();
    if (context.mounted) {
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
                      await _pickImage(ImageSource.gallery, imageUrl);
                    },
                  ),
                  const Padding(padding: EdgeInsets.all(8.0)),
                  GestureDetector(
                    child: const Text("Camera"),
                    onTap: () async {
                      await _pickImage(ImageSource.camera, imageUrl);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  static Future<void> cameraPicture(String? imageUrl) async {
    await _pickImage(ImageSource.camera, imageUrl);
  }

  static Future<void> _pickImage(ImageSource source, String? imageUrl) async {
    final pickedImage =
        await ImagePicker().pickImage(source: source, imageQuality: 10);

    if (pickedImage != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedImage.path,
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

      imageUrl = croppedFile!.path;
    }
  }
}
