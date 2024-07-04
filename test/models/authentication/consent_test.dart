import 'package:befriend/models/authentication/consent_manager.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:befriend/views/dialogs/home/consent_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'consent_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<BuildContext>(),
  MockSpec<ConsentInformation>(),
  MockSpec<ConsentDialog>(),
  MockSpec<MobileAds>(),
])
void main() {
  final mockBuildContext = MockBuildContext();
  final mockConsentInformation = MockConsentInformation();
  final mockMobileAds = MockMobileAds();
  final mockConsentDialog = MockConsentDialog();

  setUp(() {
    ConsentManager.mobileAds = mockMobileAds;
    ConsentManager.consentDialog = mockConsentDialog;
    ConsentManager.consentInformation = mockConsentInformation;
  });

  group('ConsentManager', () {
    testWidgets(
        'showTermsConditionsDialog should call _showConsentDialog with correct parameters',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    await ConsentManager.showTermsConditionsDialog(context);
                  },
                  child: const Text('Show Terms and Conditions'),
                ),
              );
            },
          ),
        ),
      );

      // Trigger the button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Assert
      verify(mockConsentDialog.showConsentDialog(any,
          dialogName: any,
          fileAddress: any));
    });

    testWidgets(
        'showPrivacyPolicyDialog should call _showConsentDialog with correct parameters',
            (WidgetTester tester) async {
          // Act
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (BuildContext context) {
                  return Scaffold(
                    body: ElevatedButton(
                      onPressed: () async {
                        await ConsentManager.showPrivacyPolicyDialog(context);
                      },
                      child: const Text('Show Privacy Policy'),
                    ),
                  );
                },
              ),
            ),
          );

          // Trigger the button
          await tester.tap(find.byType(ElevatedButton));
          await tester.pumpAndSettle();

          // Assert
          verify(mockConsentDialog.showConsentDialog(any,
              dialogName: any,
              fileAddress: any));
        });

    test('setTagForChildrenAds should set COPPA configuration for children',
        () async {
          // Arrange: Setup the mock to return false for isGDRP
          when(mockConsentInformation.getConsentStatus()).thenAnswer((_) async => ConsentStatus.notRequired);

          // Act: Call the method under test
          await ConsentManager.setTagForChildrenAds(DateTime.now().year);

          // Assert: Verify the correct configuration is set
          verify(mockMobileAds.updateRequestConfiguration(Constants.coppa)).called(1);
    });

    test('setTagForChildrenAds should set GDRP configuration for children',
        () async {
          // Arrange: Setup the mock to return false for isGDRP
          when(mockConsentInformation.getConsentStatus()).thenAnswer((_) async => ConsentStatus.required);

          // Act: Call the method under test
          await ConsentManager.setTagForChildrenAds(DateTime.now().year);

          // Assert: Verify the correct configuration is set
          verify(mockMobileAds.updateRequestConfiguration(Constants.gdrp)).called(1);
    });

    test('isGDRP should return true if consent status is not notRequired',
        () async {
      when(mockConsentInformation.getConsentStatus())
          .thenAnswer((_) async => ConsentStatus.required);
      expect(await ConsentManager.isGDRP(), isTrue);
    });

    test('isGDRP should return false if consent status is notRequired',
        () async {
      when(mockConsentInformation.getConsentStatus())
          .thenAnswer((_) async => ConsentStatus.notRequired);
      expect(await ConsentManager.isGDRP(), isFalse);
    });

    test('debugReset should call reset on ConsentInformation', () async {
      await ConsentManager.debugReset();
      verify(mockConsentInformation.reset()).called(1);
    });

    test('getConsentForm should call requestConsentInfoUpdate', () async {
      when(mockBuildContext.mounted).thenReturn(true);
      when(mockConsentInformation.isConsentFormAvailable())
          .thenAnswer((_) async => true);
      await ConsentManager.getConsentForm(mockBuildContext, reload: false);
      verify(mockConsentInformation.requestConsentInfoUpdate(any, any, any))
          .called(1);
    });
  });
}
