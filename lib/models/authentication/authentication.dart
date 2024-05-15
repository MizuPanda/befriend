import 'package:befriend/models/authentication/consent_manager.dart';
import 'package:befriend/models/data/user_manager.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../objects/home.dart';

class AuthenticationManager {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String id() {
    return _auth.currentUser?.uid ?? 'AuthenticationManager-NOT-FOUND-ID';
  }

  /// Creates a new user with email and password.
  /// The name and username are stored in the database.
  /// Returns null if the user is successfully created.
  /// Returns the error code if the user is not created.
  static Future<String?> createUserWithEmailAndPassword(
      String email,
      String password,
      String username,
      int birthYear,
      BuildContext context) async {
    String? errorCode;

    await _auth
        .createUserWithEmailAndPassword(
      email: email,
      password: password,
    )
        .then((value) async {
      User? user = value.user;
      debugPrint("Successfully created user: ${user!.uid}");
      await _registerUserData(username, birthYear, user, context);
    }).onError((FirebaseAuthException error, stackTrace) {
      //Handle every possible errors
      debugPrint('(CreateUser) An error occurred: ${error.code}');
      switch (error.code) {
        case Constants.emailAlreadyInUse:
          errorCode = error.code;
          break;
        case Constants.invalidEmail:
          errorCode = error.code;
          break;
        // Handle invalid email
        case Constants.weakPassword:
          errorCode = error.code;
          // Handle weak password
          break;
        default:
          errorCode = Constants.unknownError;
          // Handle unexpected errors
          break;
      }
    });

    return errorCode;
  }

  /// Registers the user data in the database.
  /// The name and username are stored in the database.
  /// The counter is incremented by 1 and stored in the database.
  static Future<void> _registerUserData(
      String username, int birthYear, User? user, BuildContext context) async {
    final userInfo = <String, dynamic>{
      Constants.usernameDoc: username,
      Constants.avatarDoc: '',
      Constants.friendsDoc: List.empty(),
      Constants.powerDoc: 0,
      Constants.birthYearDoc: birthYear,
      Constants.hostingDoc: List.empty(),
      Constants.sliderDoc: 0,
      Constants.hostingFriendshipsDoc: {},
      'consent': {'given': true, 'when': FieldValue.serverTimestamp()},
      Constants.blockedUsersDoc: {},
    };

    await Constants.usersCollection.doc(user!.uid).set(userInfo).then(
      //IF COMPLETED WITHOUT ERRORS
      (value) async {
        await user.sendEmailVerification();
        ConsentManager.setTagForChildrenAds(birthYear);
        if (context.mounted) {
          GoRouter.of(context).replace(Constants.pictureAddress);
        }
        debugPrint("Successfully added the data to user: $username");
      },
    ).catchError((error) async {
      // If registration data fails to save, delete the user
      debugPrint('(Authentication): An error occurred: $error');
      if (error is FirebaseException) {
        const SnackBar snackBar = SnackBar(
          content: Text("Something went wrong. Please try again later..."),
          duration: Duration(seconds: 3),
          showCloseIcon: true,
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      await user.delete();
      debugPrint(
          "(Authentication): User deleted due to failure in registration data saving");
    });
  }

  static Future<void> signIn(
      String email, String password, BuildContext context) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Home home = await UserManager.userHome();

      if (context.mounted) {
        ConsentManager.setTagForChildrenAds(home.user.birthYear);
        GoRouter.of(context).go(Constants.homepageAddress, extra: home);
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('(Authentication): ${e.code}');
      const SnackBar snackBar = SnackBar(
        content: Text(
            "Something went wrong. Please check your credentials and try again"),
        duration: Duration(seconds: 3),
        showCloseIcon: true,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }
}
