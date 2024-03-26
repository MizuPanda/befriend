import 'package:befriend/models/authentication/consent_manager.dart';
import 'package:befriend/views/widgets/settings/archive_settings_widget.dart';
import 'package:befriend/views/widgets/settings/blocked_settings_widget.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/data/user_manager.dart';
import '../models/objects/bubble.dart';
import '../utilities/constants.dart';
import '../views/widgets/settings/consent_settings_widget.dart';

class SettingsProvider extends ChangeNotifier {
  Future<void> signOut(BuildContext context) async {
    debugPrint('(SettingsPage): Signing out');

    await FirebaseAuth.instance.signOut();
    UserManager.refreshPlayer();
    if (context.mounted) {
      GoRouter.of(context).go(Constants.loginAddress);
    }
  }

  void goToBlockedSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BlockedSettingsWidget(),
      ),
    );
  }

  void goToArchiveSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ArchiveSettingsWidget(),
      ),
    );
  }

  void goToConsentSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConsentSettingsWidget(
          provider: this,
        ),
      ),
    );
  }

  void openPrivacyPolicy(BuildContext context) {
    ConsentManager.showPrivacyPolicyDialog(context);
  }

  void openTermsAndConditions(BuildContext context) {
    ConsentManager.showTermsConditionsDialog(context);
  }

  void openTutorial(BuildContext context) {}

  void reloadConsentForm() {
    ConsentManager.getConsentForm(reload: true);
  }

  Future<void> showDeleteAccountConfirmation(BuildContext context) async {
    // Show confirmation dialog
    final bool confirmed = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              titleTextStyle: GoogleFonts.openSans(
                  color: ThemeData().primaryColor, fontSize: 26),
              contentTextStyle: GoogleFonts.openSans(
                  fontStyle: FontStyle.italic,
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
              title: const Text('Delete Account'),
              content: const Text(
                  'Are you sure you want to delete your account? This action cannot be undone.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child:
                      const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        ) ??
        false; // Assume 'false' if null is returned (dialog dismissed)

    // If confirmed, proceed with account deletion
    if (confirmed) {
      // Call your function to delete the account here
      // For example: deleteUserAccount();
      if (context.mounted) {
        debugPrint('(SettingsProvider): User confirmed account deletion');

        await _deleteAccount(context);
      }
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    try {
      final FirebaseFunctions functions = FirebaseFunctions.instance;
      final Bubble user = await UserManager.getInstance();
      final List<String> friendshipsIds = [];

      for (String friendId in user.friendIDs) {
        final List<String> ids = [friendId, user.id];
        ids.sort();

        friendshipsIds.add(ids.first + ids.last);
      }

      final Map<String, dynamic> data = {
        'uid': user.id,
        'friendshipIds': friendshipsIds,
        'friendIds': user.friendIDs,
      };

      // Calling the 'deleteUserData' Cloud Function
      HttpsCallable callable = functions.httpsCallable('deleteUserData');
      final result = await callable.call(data);
      // Handle the function response
      debugPrint('(SettingsProvider): Function result: ${result.data}');

      // Sign out the user
      if (context.mounted) {
        signOut(context);
      }
    } on FirebaseFunctionsException catch (e) {
      // Handle Firebase Functions exception
      debugPrint(
          '(SettingsProvider): FirebaseFunctionsException= ${e.code} - ${e.message}');
    } catch (e) {
      // Handle other exceptions
      debugPrint('(SettingsProvider): General Exception: $e');
    }
  }
}
