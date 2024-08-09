import 'package:befriend/models/authentication/consent_manager.dart';
import 'package:befriend/models/data/user_manager.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:befriend/utilities/error_handling.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../utilities/app_localizations.dart';
import '../objects/home.dart';

class AuthenticationManager {
  static FirebaseAuth _auth = FirebaseAuth.instance;

  /// For testing reasons
  static set auth(FirebaseAuth value) {
    _auth = value;
  }

  static String id() {
    return _auth.currentUser?.uid ?? 'AuthenticationManager-NOT-FOUND-ID';
  }

  static bool isConnected() {
    return _auth.currentUser?.uid != null;
  }

  static String archivedID() {
    return '${Constants.archived}${_auth.currentUser?.uid}';
  }

  static String notArchivedID() {
    return '${Constants.notArchived}${_auth.currentUser?.uid}';
  }

  static bool isEmailVerified() {
    return _auth.currentUser?.emailVerified ?? false;
  }

  static void sendEmailVerification(BuildContext context) {
    try {
      _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      debugPrint('(AuthenticationManager) Error sending email verification');
      ErrorHandling.showError(
          context,
          AppLocalizations.of(context)?.translate('auth_sev_error') ??
              'There was an error sending the verification email. Please try again later.');
    }
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

    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;
      if (user != null) {
        if (context.mounted) {
          await _registerUserData(username, birthYear, user, context);
        }
        debugPrint(
            "(AuthenticationManager) Successfully created user: ${user.uid}");
        FirebaseAnalytics.instance
            .logSignUp(signUpMethod: 'email_and_password');
      }
    } on FirebaseAuthException catch (error) {
      debugPrint('(AuthenticationManager) An error occurred: ${error.code}');
      errorCode = error.code;
    }

    return errorCode;
  }

  /// Registers the user data in the database.
  /// The name and username are stored in the database.
  /// The counter is incremented by 1 and stored in the database.
  static Future<void> _registerUserData(
      String username, int birthYear, User? user, BuildContext context) async {
    final String languageCode = Localizations.localeOf(context).languageCode;

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
      Constants.likeNotificationOnDoc: true,
      Constants.postNotificationOnDoc: true,
      Constants.languageDoc: languageCode,
      Constants.inviteTokensDoc: {},
    };

    try {
      await Constants.usersCollection.doc(user!.uid).set(userInfo);
      await user.sendEmailVerification();
      ConsentManager.setTagForChildrenAds(birthYear);
      if (context.mounted) {
        GoRouter.of(context).replace(Constants.pictureAddress);
      }

      debugPrint("Successfully added the data to user: $username");
    } on FirebaseException catch (error) {
      // If registration data fails to save, delete the user
      debugPrint('(AuthenticationManager) A Firebase error occurred: $error');

      if (context.mounted) {
        ErrorHandling.showError(
            context,
            AppLocalizations.of(context)?.translate('general_error_message') ??
                "Something went wrong. Please try again later...");
      }

      await user?.delete();
      debugPrint(
          "(AuthenticationManager) User deleted due to failure in registration data saving");
    } catch (error) {
      debugPrint('(AuthenticationManager) An unknown error occurred: $error');
    }
  }

  static Future<void> signIn(
      String email, String password, BuildContext context) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (context.mounted) {
        Home home = await UserManager.userHome();

        ConsentManager.setTagForChildrenAds(home.user.birthYear);

        if (context.mounted) {
          GoRouter.of(context).go(Constants.homepageAddress, extra: home);
        }

        FirebaseAnalytics.instance.logLogin(loginMethod: 'email_and_password');
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('(AuthenticationManager): ${e.code}');

      if (context.mounted) {
        ErrorHandling.showError(
            context,
            AppLocalizations.of(context)?.translate('auth_sign_error') ??
                "Something went wrong. Please check your credentials and try again");
      }
    }
  }
}
