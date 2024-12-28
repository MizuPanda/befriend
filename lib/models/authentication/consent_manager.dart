import 'package:befriend/utilities/error_handling.dart';
import 'package:befriend/views/dialogs/home/consent_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../utilities/app_localizations.dart';
import '../../utilities/constants.dart';

class ConsentManager {
  static MobileAds _mobileAds = MobileAds.instance;
  static ConsentDialog _consentDialog = ConsentDialog();
  static ConsentInformation _consentInformation = ConsentInformation.instance;

  /// For testing purpose
  static set mobileAds(MobileAds value) {
    _mobileAds = value;
  }

  static set consentDialog(ConsentDialog value) {
    _consentDialog = value;
  }

  static set consentInformation(ConsentInformation value) {
    _consentInformation = value;
  }

  static Future<void> showTermsConditionsDialog(BuildContext context) async {
    try {
      // Get the current locale
      Locale currentLocale = Localizations.localeOf(context);
      // Extract the language code
      String languageCode = currentLocale.languageCode;

      String address = '${Constants.termsAddress}_$languageCode.md';

      debugPrint("(ConsentManager) Address=$address");

      await _showConsentDialog(context,
          fileAddress: address,
          dialogName: AppLocalizations.translate(context,
              key: 'cm_tc', defaultString: 'Terms & Conditions'));
    } catch (e) {
      debugPrint(
          '(ConsentManager): Error displaying terms and conditions dialog: $e');
      // Provide user feedback or log error
      if (context.mounted) {
        ErrorHandling.showError(
            context,
            AppLocalizations.translate(context,
                key: 'cm_terms_error',
                defaultString:
                    'Failed to display the terms and conditions. Please try again.'));
      }
    }
  }

  static Future<void> showPrivacyPolicyDialog(BuildContext context) async {
    try {
      // Get the current locale
      Locale currentLocale = Localizations.localeOf(context);
      // Extract the language code
      String languageCode = currentLocale.languageCode;

      String address = '${Constants.privacyAddress}_$languageCode.md';

      await _showConsentDialog(context,
          fileAddress: address,
          dialogName: AppLocalizations.translate(context,
              key: 'cm_pp', defaultString: 'Privacy Policy'));
    } catch (e) {
      debugPrint('(ConsentManager): Error displaying privacy dialog: $e');
      // Provide user feedback or log error
      if (context.mounted) {
        ErrorHandling.showError(
            context,
            AppLocalizations.translate(context,
                key: 'cm_privacy_error',
                defaultString:
                    'Failed to display the privacy policy. Please try again.'));
      }
    }
  }

  static Future<void> _showConsentDialog(BuildContext context,
      {required String fileAddress, required String dialogName}) async {
    return _consentDialog.showConsentDialog(context,
        dialogName: dialogName, fileAddress: fileAddress);
  }

  static Future<void> setTagForChildrenAds(int birthYear) async {
    if (birthYear >= DateTime.now().year - 18) {
      if (!(await isGDRP())) {
        debugPrint('(ConsentManager): Setting child COPPA');
        // COPPA REQUIREMENTS
        _mobileAds.updateRequestConfiguration(Constants.coppa);
      } else {
        debugPrint('(ConsentManager): Setting child GDRP');
        // GDRP REQUIREMENTS
        _mobileAds.updateRequestConfiguration(Constants.gdrp);
      }
    }
  }

  static Future<bool> isGDRP() async {
    debugPrint(
        "(ConsentManager): Consent Status= ${(await _consentInformation.getConsentStatus())}");
    return (await _consentInformation.getConsentStatus()) !=
        ConsentStatus.notRequired;
  }

  static Future<void> debugReset() async {
    await _consentInformation.reset();
  }

  static Future<void> getConsentForm(BuildContext context,
      {required bool reload}) async {
    final params = ConsentRequestParameters(
        // consentDebugSettings: Secrets.consentDebugSettings
        );
    _consentInformation.requestConsentInfoUpdate(
      params,
      () async {
        if (await _consentInformation.isConsentFormAvailable()) {
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
            context,
            AppLocalizations.translate(context,
                key: 'cm_form_error',
                defaultString:
                    "Failed to update consent information. Please try again."));
      },
    );
  }

  /// For testing purposes
  static void testLoadForm(BuildContext context, bool reload) {
    _loadForm(context, reload);
  }

  static void _loadForm(BuildContext context, bool reload) {
    ConsentForm.loadConsentForm(
      (ConsentForm consentForm) async {
        ConsentStatus status = await _consentInformation.getConsentStatus();

        debugPrint('(ConsentManager) Status is $status');
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
      (FormError formError) {
        // Handle the error
        debugPrint(
            '(ConsentManager) Error loading consent form; ${formError.message}');
      },
    );
  }
}
