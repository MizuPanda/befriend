import 'dart:io';

import 'package:flutter/material.dart';

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
  final TextEditingController _nameController = TextEditingController();

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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              'Edit Profile',
              style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20.0),
            SizedBox(
              width: 150,
              height: 110,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  InkWell(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: _imageUrl != null
                          ? FileImage(File(_imageUrl!))
                          : widget.bubble.avatar,
                      child: _imageUrl == null
                          ? Icon(Icons.add_a_photo,
                              size: 50, color: Colors.black.withOpacity(0.5))
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
                          color: Colors.black,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                // Handle save profile data
                if (_imageUrl != null) {
                  await PictureManager.changeMainPicture(
                      _imageUrl!, widget.bubble);
                }
                if (context.mounted) {
                  widget.notifyParent();
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
