import 'dart:io';

import 'package:befriend/providers/material_provider.dart';
import 'package:befriend/views/dialogs/rounded_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/data/picture_manager.dart';
import '../../../models/objects/bubble.dart';

class ProfileEditDialog extends StatefulWidget {
  const ProfileEditDialog(
      {super.key, required this.bubble, required this.notifyParent});

  final Bubble bubble;
  final Function notifyParent;

  @override
  State<ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<ProfileEditDialog> {
  String? _imageUrl;

  Future<void> _pickImage() async {
    await PictureManager.takeProfilePicture(context, (String? imageUrl) {
      if (imageUrl != null) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          setState(() {
            _imageUrl = imageUrl;
          });
        });
      }
    });
  }

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Consumer<MaterialProvider>(builder: (BuildContext context,
        MaterialProvider materialProvider, Widget? child) {
      final bool lightMode = materialProvider.isLightMode(context);

      return RoundedDialog(
        child: Container(
          padding: EdgeInsets.all(0.036 * width),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
          ),
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Edit Profile',
                style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 0.020 * height),
              SizedBox(
                width: 0.33 * width,
                height: 0.11 * height,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    InkWell(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: width * 0.11,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: _imageUrl != null
                            ? FileImage(File(_imageUrl!))
                            : widget.bubble.avatar,
                        child: _imageUrl == null
                            ? Icon(Icons.add_a_photo,
                                size: 50,
                                color: (lightMode ? Colors.black : Colors.white)
                                    .withOpacity(0.5))
                            : null,
                      ),
                    ),
                    if (_imageUrl != null)
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              _imageUrl = null;
                            });
                          },
                          icon: const Icon(
                            Icons.cancel_outlined,
                            size: 30,
                            color: Colors.pink,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 0.020 * height),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  // Handle save profile data
                  if (_imageUrl != null) {
                    await PictureManager.changeMainPicture(
                        context, _imageUrl!, widget.bubble);
                    setState(() {
                      _isLoading = false;
                    });
                    widget.notifyParent();
                  }
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                style: ButtonStyle(
                  padding: MaterialStatePropertyAll(EdgeInsets.symmetric(
                      horizontal: 0.11 * width, vertical: 0.015 * height)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text(
                        'Save',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
              TextButton(
                  onPressed: () async {
                    await PictureManager.removeMainPicture(
                        context, widget.bubble);
                    widget.notifyParent();
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Remove your profile picture')),
            ],
          ),
        ),
      );
    });
  }
}
