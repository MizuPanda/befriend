import 'dart:io';

import 'package:befriend/models/data_query.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as path;


class PictureQuery {
  static Future<void> uploadAvatar(File imageFile) async {
    String? downloadUrl = await _uploadProfilePicture(imageFile);
    if(downloadUrl != null) {
      DataQuery.updateAvatar(downloadUrl);
      debugPrint('Avatar updated');
    }
  }
  static Future<String?> _uploadProfilePicture(File imageFile) async {
    // Get current user's UID
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('No user signed in.');
      return null;
    }
    String uid = user.uid;

    // Get file extension
    String fileExtension = path.extension(imageFile.path);

    // Create a reference to the user's profile picture
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('profile_pictures')
        .child('$uid$fileExtension');

    // Upload file
    try {
      await ref.putFile(imageFile);
      // Get file URL
      String downloadURL = await ref.getDownloadURL();
      debugPrint('Profile picture uploaded successfully. URL: $downloadURL');
      return downloadURL;
    } catch (e) {
      debugPrint('Error uploading profile picture: $e');
      return null;
    }
  }
}