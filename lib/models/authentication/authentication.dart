import 'package:befriend/models/data/data_manager.dart';
import 'package:befriend/models/data/user_manager.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class AuthenticationManager {
  static final FirebaseFirestore _store = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String id() {
    return _auth.currentUser!.uid;
  }

  /// Creates a new user with email and password.
  /// The name and username are stored in the database.
  /// Returns null if the user is successfully created.
  /// Returns the error code if the user is not created.
  static Future<String?> createUserWithEmailAndPassword(
      String email,
      String password,
      String name,
      String username,
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
      await _registerUserData(name, username, user, context);
    }).onError((FirebaseAuthException error, stackTrace) {
      //Handle every possible errors
      debugPrint('(CreateUser) An error occurred: ${error.code}');
      switch (error.code) {
        case 'email-already-in-use':
          errorCode = error.code;
      }
    });

    return errorCode;
  }

  /// Registers the user data in the database.
  /// The name and username are stored in the database.
  /// The counter is incremented by 1 and stored in the database.
  static Future<void> _registerUserData(
      String name, String username, User? user, BuildContext context) async {
    final DocumentReference numbersDoc =
        _store.collection("data").doc("numbers");

    _store.runTransaction((transaction) async {
      final DocumentSnapshot numberSnap = await transaction.get(numbersDoc);

      transaction
          .update(numbersDoc, {Constants.counterDoc: FieldValue.increment(1)});

      num counter = DataManager.getNumber(numberSnap, Constants.counterDoc);
      final userInfo = <String, dynamic>{
        Constants.nameDoc: name,
        Constants.usernameDoc: username,
        Constants.counterDoc: counter + 1,
        Constants.avatarDoc: '',
        Constants.friendsDoc: List.empty(),
        Constants.powerDoc: 0,
        Constants.hostingDoc: List.empty(),
        Constants.sliderDoc: 0
      };

      final DocumentReference userDoc =
          _store.collection("users").doc(_auth.currentUser?.uid);

      transaction.set(userDoc, userInfo);

      _auth.currentUser?.updateDisplayName(name);
    }).then(
      //IF COMPLETED WITHOUT ERRORS
      (value) async {
        await user?.sendEmailVerification();

        if (context.mounted) {
          GoRouter.of(context).replace('/picture');
        }
        debugPrint("Successfully added the data to user: $username");
      },
    ).catchError((error) {
      // If registration data fails to save, delete the user
      debugPrint('(RegisterUser) An error occurred: ${error.toString()}');
      user?.delete();
      debugPrint("User deleted due to failure in registration data saving");
    });
  }

  static Future<void> signIn(
      String email, String password, BuildContext context) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (context.mounted) {
        GoRouter.of(context)
            .replace('/homepage', extra: await UserManager.userHome());
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('(Authentication-Error): ${e.code}');
      if (context.mounted) {
        showTopSnackBar(
            Overlay.of(context),
            const CustomSnackBar.error(
              message:
                  "Something went wrong. Please check your credentials and try again",
            ),
            snackBarPosition: SnackBarPosition.bottom);
      }
    }
  }
}
