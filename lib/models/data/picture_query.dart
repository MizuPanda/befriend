import 'dart:io';

import 'package:befriend/models/data/data_query.dart';
import 'package:befriend/models/objects/host.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as path;

class PictureQuery {
  static Reference _hostSessionRef(Host host) {
    return FirebaseStorage.instance
        .ref()
        .child(Constants.sessionPictureStorage)
        .child(host.host.id);
  }

  static Future<void> removeProfilePicture() async {
    try {
      await DataQuery.updateDocument(Constants.avatarDoc, '');
    } catch (e) {
      debugPrint('(PictureQuery): Error removing avatar: $e');
    }
  }

  static Future<String?> uploadAvatar(File imageFile) async {
    try {
      String? downloadUrl = await _uploadProfilePicture(imageFile);
      if (downloadUrl != null) {
        await DataQuery.updateDocument(Constants.avatarDoc, downloadUrl);
        debugPrint('(PictureQuery): Avatar updated');
      }
      return downloadUrl;
    } catch (e) {
      debugPrint('(PictureQuery): Error uploading avatar: $e');
      rethrow;
    }
  }

  static Future<String?> uploadTempPicture(
      Host host, List<dynamic> sessionUsers) async {
    try {
      String? downloadUrl = await _uploadPictureForSession(host);
      if (downloadUrl != null) {
        List<dynamic> lst = ['${Constants.pictureMarker}$downloadUrl'];
        lst.addAll(sessionUsers);
        await DataQuery.updateDocument(Constants.hostingDoc, lst);
      }
      return downloadUrl;
    } catch (e) {
      debugPrint('(PictureQuery): Error uploading temporary picture: $e');
      rethrow;
    }
  }

  static Future<String?> _uploadPictureForSession(
    Host host,
  ) async {
    try {
      File file = host.tempFile();
      // Get file extension
      String fileExtension = path.extension(file.path);

      // Get the timestamp
      String dateTime = DateTime.timestamp().toString();

      // Create fileName
      String fileName = '${dateTime}_${host.host.id}$fileExtension';

      // Create a reference to the user's profile picture
      Reference ref = _hostSessionRef(host)
          .child(Constants.tempPictureStorage)
          .child(fileName);

      return await _uploadFile(ref, file);
    } catch (e) {
      debugPrint('(PictureQuery): Error uploading picture for session: $e');
      rethrow;
    }
  }

  static Future<String?> _uploadProfilePicture(File imageFile) async {
    try {
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
          .child(Constants.profilePictureStorage)
          .child('$uid$fileExtension');

      // Upload file
      return await _uploadFile(ref, imageFile);
    } catch (e) {
      debugPrint('(PictureQuery): Error uploading profile picture: $e');
      rethrow;
    }
  }

  static Future<String?> _uploadFile(Reference ref, File file) async {
    try {
      await ref.putFile(file);
      // Get file URL
      String downloadURL = await ref.getDownloadURL();
      debugPrint(
          '(PictureQuery): Profile picture uploaded successfully. URL: $downloadURL');
      return downloadURL;
    } catch (e) {
      debugPrint('(PictureQuery): Error uploading profile picture file: $e');
      rethrow;
    }
  }

  static Future<String?> movePictureToPermanentStorage(
    Host host,
  ) async {
    try {
      String tempDownloadUrl = host.imageUrl!;

      // Extract the file name from the temporary download URL
      String fileName = tempDownloadUrl.split('/').last.split('?').first;
      fileName.substring('session_pictures%2'.length);

      debugPrint('(PictureQuery): File name = $fileName');

      // Get a reference to the permanent location
      Reference permRef = _hostSessionRef(host)
          .child(Constants.postedPictureStorage)
          .child(fileName);

      String? downloadUrl = await _uploadFile(permRef, host.tempFile());

      return downloadUrl;
    } catch (e) {
      debugPrint(
          '(PictureQuery): Error moving picture to permanent storage: $e');
      rethrow;
    }
  }

  // Function to delete all pictures in the temporary directory
  static Future<void> deleteTemporaryPictures(Host host) async {
    try {
      // Get reference to the temp directory
      Reference tempDirRef =
          _hostSessionRef(host).child(Constants.tempPictureStorage);

      // List all items (files) within the directory
      ListResult items = await tempDirRef.listAll();
      for (Reference item in items.items) {
        await item.delete(); // Delete each item
        debugPrint('(PictureQuery): Deleting ${item.name}');
      }
    } catch (e) {
      debugPrint('(PictureQuery): Error deleting temporary pictures: $e');
    }
  }
}
