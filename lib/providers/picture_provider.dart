import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user.dart';

class PictureSignProvider extends ChangeNotifier {
  final Color foregroundColor = const Color(0xFF1F465E);

  String? _imagePath;

  bool imageNull() {
    return _imagePath == null;
  }

  Image image() {
    return Image.file(File(_imagePath!));
  }

  Future<void> showChoiceDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Make a choice!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const Text("Gallery"),
                  onTap: () async {
                    await _pickImage(ImageSource.gallery, context);
                  },
                ),
                const Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: const Text("Camera"),
                  onTap: () async {
                    await _pickImage(ImageSource.camera, context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source, BuildContext context) async {
    final pickedImage = await ImagePicker().pickImage(source: source);

    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedImage!.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: foregroundColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ],
    );
    _imagePath = croppedFile!.path;
    notifyListeners();
    if (context.mounted) {
      GoRouter.of(context).pop();
    }
  }

  void goHome(BuildContext context) {
    GoRouter.of(context).push('/homepage', extra: UserManager.userHome());
  }
}
