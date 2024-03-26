import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class ConsentManager {
  static const String _termsAddress = 'assets/terms_and_conditions.md';
  static const String _termsDialogName = 'Terms & Conditions';

  static const String _privacyAddress = 'assets/privacy_policy.md';
  static const String _privacyDialogName = 'Privacy Policy';

  static Future<void> showTermsConditionsDialog(BuildContext context) async {
    await _showConsentDialog(context, _termsAddress, _termsDialogName);
  }

  static Future<void> showPrivacyPolicyDialog(BuildContext context) async {
    await _showConsentDialog(context, _privacyAddress, _privacyDialogName);
  }

  static Future<void> _showConsentDialog(
      BuildContext context, String fileAddress, String dialogName) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(dialogName),
          content: FutureBuilder(
            future: DefaultAssetBundle.of(context).loadString(fileAddress),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasData) {
                return SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: Markdown(data: snapshot.data ?? ''));
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
    return (await ConsentInformation.instance.getConsentStatus()) !=
        ConsentStatus.notRequired;
  }

  static Future<void> debugReset() async {
    await ConsentInformation.instance.reset();
  }

  static Future<void> getConsentForm({required bool reload}) async {
    final params = ConsentRequestParameters(
        // consentDebugSettings: Secrets.consentDebugSettings
        );
    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () async {
        if (await ConsentInformation.instance.isConsentFormAvailable()) {
          debugPrint('(Consent): Consent form is available.');
          _loadForm(reload);
        }
      },
      (FormError error) {
        // Handle the error
        debugPrint("(Consent): Error getting consent form; $error");
      },
    );
  }

  static void _loadForm(bool reload) {
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
              _loadForm(false);
            },
          );
        }
      },
      (formError) {
        // Handle the error
      },
    );
  }
}
