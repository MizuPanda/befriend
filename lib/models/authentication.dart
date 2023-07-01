import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthenticationManager {
  static final FirebaseFirestore _store = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

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
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      debugPrint("Successfully created user: ${user!.uid}");
      await _registerUserData(name, username);
      await user.sendEmailVerification();
      if (context.mounted) {
        GoRouter.of(context).push('/verification');
      }
    } on FirebaseAuthException catch (e) {
      debugPrint(e.code);
      return e.code;
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: ${e.code}'),
        ),
      );
    }

    return null;
  }

  /// Registers the user data in the database.
  /// The name and username are stored in the database.
  /// The counter is incremented by 1 and stored in the database.
  static Future<void> _registerUserData(
    String name,
    String username,
  ) async {
    await _store
        .collection('data')
        .doc('numbers')
        .update({'counter': FieldValue.increment(1)});

    DocumentSnapshot docs =
        await _store.collection('data').doc('numbers').get();

    int counter =
        docs.data().toString().contains('counter') ? docs.get('counter') : 0;

    final userInfo = <String, dynamic>{
      "name": name,
      "username": username,
      'counter': counter,
      'avatar': '',
    };

    _store
        .collection("users")
        .doc(_auth.currentUser?.uid)
        .set(userInfo)
        .whenComplete(
            () => debugPrint("Successfully added the data to user: $username"))
        .onError((e, _) {
      debugPrint("Error writing document: $e");
      throw e!;
      //SHOW ERROR DIALOG
    });
    _auth.currentUser?.updateDisplayName(name);
  }

  static Future<void> signIn(
      String email, String password, BuildContext context) async {
    try {
      _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      debugPrint('(Error): ${e.code}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error. Incorrect email or password.'),
        ),
      );
    } on Error catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint('Password reset email sent successfully.');
    } catch (e) {
      debugPrint('Failed to send password reset email: $e');
    }
  }

  static Future<String?> verifyEmail(String verificationCode) async {
    try {
      await _auth.applyActionCode(verificationCode);
      // Email verified successfully
      //GO TO TAKE AVATAR PAGE
    } on FirebaseAuthException catch (e) {
      // Handle verification errors
      return e.code;
    }
    return null;
  }
}
