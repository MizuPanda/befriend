import 'package:befriend/models/authentication/consent_manager.dart';
import 'package:befriend/utilities/error_handling.dart';
import 'package:befriend/views/dialogs/settings/contact_dialog.dart';
import 'package:befriend/views/dialogs/settings/delete_account_dialog.dart';
import 'package:befriend/views/widgets/settings/archive_settings_widget.dart';
import 'package:befriend/views/widgets/settings/blocked_settings_widget.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/data/user_manager.dart';
import '../models/objects/bubble.dart';
import '../models/objects/home.dart';
import '../utilities/constants.dart';
import '../views/widgets/settings/consent_settings_widget.dart';

class SettingsProvider extends ChangeNotifier {
  Future<void> signOut(BuildContext context) async {
    try {
      debugPrint('(SettingsPage): Signing out');

      await FirebaseAuth.instance.signOut();
      UserManager.refreshPlayer();
      if (context.mounted) {
        GoRouter.of(context).go(Constants.loginAddress);
      }
    } catch (e) {
      debugPrint('(SettingsProvider): Error signing out: $e');
      if (context.mounted) {
        ErrorHandling.showError(
            context, 'Error signing out. Please try again.');
      }
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

  Future<void> openTutorial(BuildContext context) async {
    try {
      Home home = await UserManager.userHome();
      home.activeTutorial();

      if (context.mounted) {
        GoRouter.of(context).push(Constants.homepageAddress, extra: home);
      }
    } catch (e) {
      debugPrint('(SettingsProvider): Error opening tutorial: $e');
      if (context.mounted) {
        ErrorHandling.showError(
            context, 'Error opening tutorial. Please try again.');
      }
    }
  }

  void openContact(BuildContext context) {
    ContactDialog.showEmailDialog(context);
  }

  void reloadConsentForm(BuildContext context) {
    ConsentManager.getConsentForm(context, reload: true);
  }

  Future<void> showDeleteAccountConfirmation(BuildContext context) async {
    try {
      final bool confirmed = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return DeleteAccountDialog.dialog(context);
            },
          ) ??
          false;

      if (confirmed) {
        if (context.mounted) {
          debugPrint('(SettingsProvider): User confirmed account deletion');
          await _deleteAccount(context);
        }
      }
    } catch (e) {
      debugPrint(
          '(SettingsProvider): Error showing delete account confirmation: $e');
      if (context.mounted) {
        ErrorHandling.showError(
            context, 'Error showing confirmation. Please try again.');
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

      HttpsCallable callable = functions.httpsCallable('deleteUserData');
      final result = await callable.call(data);
      debugPrint('(SettingsProvider): Function result: ${result.data}');

      if (context.mounted) {
        signOut(context);
      }
    } on FirebaseFunctionsException catch (e) {
      debugPrint(
          '(SettingsProvider): FirebaseFunctionsException= ${e.code} - ${e.message}');
      if (context.mounted) {
        ErrorHandling.showError(
            context, 'Error deleting account. Please try again.');
      }
    } catch (e) {
      debugPrint('(SettingsProvider): General Exception: $e');
      if (context.mounted) {
        ErrorHandling.showError(
            context, 'Error deleting account. Please try again.');
      }
    }
  }
}
