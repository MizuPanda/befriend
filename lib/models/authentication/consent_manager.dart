import 'package:befriend/utilities/error_handling.dart';
import 'package:befriend/views/dialogs/home/consent_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../utilities/constants.dart';

class ConsentManager {
  static const String _termsDialogName = 'Terms & Conditions';

  static const String _privacyDialogName = 'Privacy Policy';

  static Future<void> showTermsConditionsDialog(BuildContext context) async {
    try {
      await _showConsentDialog(
          context, Constants.termsAddress, _termsDialogName);
    } catch (e) {
      debugPrint(
          '(ConsentManager): Error displaying terms and conditions dialog: $e');
      // Provide user feedback or log error
      if (context.mounted) {
        ErrorHandling.showError(context,
            'Failed to display the terms and conditions. Please try again.');
      }
    }
  }

  static Future<void> showPrivacyPolicyDialog(BuildContext context) async {
    try {
      await _showConsentDialog(
          context, Constants.privacyAddress, _privacyDialogName);
    } catch (e) {
      debugPrint('(ConsentManager): Error displaying privacy dialog: $e');
      // Provide user feedback or log error
      if (context.mounted) {
        ErrorHandling.showError(
            context, 'Failed to display the privacy policy. Please try again.');
      }
    }
  }

  static Future<void> _showConsentDialog(
      BuildContext context, String fileAddress, String dialogName) async {
    return ConsentDialog.showConsentDialog(context, dialogName, fileAddress);
  }

  static void setTagForChildrenAds(int birthYear) async {
    if (birthYear >= DateTime.now().year - 18) {
      if (!(await isGDRP())) {
        debugPrint('(ConsentManager): Setting child COPPA');
        // COPPA REQUIREMENTS
        final RequestConfiguration requestConfiguration = RequestConfiguration(
            tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes);
        MobileAds.instance.updateRequestConfiguration(requestConfiguration);
      } else {
        debugPrint('(ConsentManager): Setting child GDRP');
        // GDRP REQUIREMENTS
        final RequestConfiguration requestConfiguration = RequestConfiguration(
            tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.yes);
        MobileAds.instance.updateRequestConfiguration(requestConfiguration);
      }
    }
  }

  static Future<bool> isGDRP() async {
    debugPrint(
        "(ConsentManager): Consent Status= ${(await ConsentInformation.instance.getConsentStatus())}");
    return (await ConsentInformation.instance.getConsentStatus()) !=
        ConsentStatus.notRequired;
  }

  static Future<void> debugReset() async {
    await ConsentInformation.instance.reset();
  }

  static Future<void> getConsentForm(BuildContext context,
      {required bool reload}) async {
    final params = ConsentRequestParameters(
        // consentDebugSettings: Secrets.consentDebugSettings
        );
    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () async {
        if (await ConsentInformation.instance.isConsentFormAvailable()) {
          debugPrint('(ConsentManager): Consent form is available.');
          if (context.mounted) {
            _loadForm(context, reload);
          }
        }
      },
      (FormError error) {
        // Handle the error
        debugPrint("(ConsentManager): Error getting consent form; $error");

        // Consider adding retry logic or a user notification here
        ErrorHandling.showError(
            context, "Failed to update consent information. Please try again.");
      },
    );
  }

  static void _loadForm(BuildContext context, bool reload) {
    ConsentForm.loadConsentForm(
      (ConsentForm consentForm) async {
        ConsentStatus status =
            await ConsentInformation.instance.getConsentStatus();

        debugPrint('(Consent): Status is $status');
        if (status == ConsentStatus.required ||
            (status == ConsentStatus.obtained && reload)) {
          consentForm.show(
            (FormError? formError) {
              // Handle dismissal by reloading form
              _loadForm(context, false);
            },
          );
        }
      },
      (formError) {
        // Handle the error
        debugPrint('(ConsentManager): Error loading consent form; $formError');
        // Inform the user or retry loading the form
        ErrorHandling.showError(
            context, "Failed to load the consent form. Please try again.");
      },
    );
  }
}
