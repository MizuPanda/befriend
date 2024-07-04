import 'package:befriend/models/authentication/authentication.dart';
import 'package:befriend/models/objects/bubble.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:befriend/utilities/models.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../firebase_mock.dart';
import 'authentication_test.mocks.dart';

// Use @GenerateNiceMocks for BuildContext
@GenerateNiceMocks([
  MockSpec<FirebaseAuth>(),
  MockSpec<User>(),
  MockSpec<UserCredential>(),
  MockSpec<BuildContext>(),
  MockSpec<Bubble>(),
])

void main() {
  // TestWidgetsFlutterBinding.ensureInitialized(); Gets called in setupFirebaseAuthMocks()
  setupFirebaseAuthMocks();

  final mockFirebaseAuth = MockFirebaseAuth();
  final mockUser = MockUser();
  final mockUserCredential = MockUserCredential();
  final mockBuildContext = MockBuildContext();
  final fakeFirestore = FakeFirebaseFirestore();

  setUp(() {
    when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('test-uid');
    Constants.usersCollection = fakeFirestore.collection('users');
    Constants.friendshipsCollection = fakeFirestore.collection('friendships');
  });

  group('AuthenticationManager', () {
    test('id should return user id if user is signed in', () {
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      AuthenticationManager.auth = mockFirebaseAuth;  // Ensure the singleton instance uses the mock
      expect(Models.authenticationManager.id(), 'test-uid');
    });

    test('id should return fallback string if user is not signed in', () {
      when(mockFirebaseAuth.currentUser).thenReturn(null);
      AuthenticationManager.auth = mockFirebaseAuth;  // Ensure the singleton instance uses the mock
      expect(Models                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   .authenticationManager.id(), 'AuthenticationManager-NOT-FOUND-ID');
    });

    test('isEmailVerified should return true if email is verified', () {
      when(mockUser.emailVerified).thenReturn(true);
      AuthenticationManager.auth = mockFirebaseAuth;  // Ensure the singleton instance uses the mock
      expect(AuthenticationManager.isEmailVerified(), isTrue);
    });

    test('isEmailVerified should return false if email is not verified', () {
      when(mockUser.emailVerified).thenReturn(false);
      AuthenticationManager.auth = mockFirebaseAuth;  // Ensure the singleton instance uses the mock
      expect(AuthenticationManager.isEmailVerified(), isFalse);
    });

    test('sendEmailVerification should call sendEmailVerification on user', () {
      when(mockUser.sendEmailVerification())
          .thenAnswer((_) async => Future.value());
      AuthenticationManager.auth = mockFirebaseAuth;  // Ensure the singleton instance uses the mock
      AuthenticationManager.sendEmailVerification(mockBuildContext);
      verify(mockUser.sendEmailVerification()).called(1);
    });

    test('createUserWithEmailAndPassword should return error code on failure', () async {
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
          email: 'test@example.com', password: 'password'))
          .thenThrow(FirebaseAuthException(code: Constants.emailAlreadyInUse, message: 'The email address is already in use by another account.'));

      AuthenticationManager.auth = mockFirebaseAuth;  // Ensure the singleton instance uses the mock

      final errorCode = await AuthenticationManager.createUserWithEmailAndPassword(
          'test@example.com', 'password', 'username', 2000, mockBuildContext);

      expect(errorCode, Constants.emailAlreadyInUse);
    });

    test(
        'createUserWithEmailAndPassword should return null on success',
            () async {
          when(mockFirebaseAuth.createUserWithEmailAndPassword(
              email: 'test@example.com', password: 'password'))
              .thenAnswer((_) async => mockUserCredential);
          when(mockUserCredential.user).thenReturn(mockUser);
          when(mockBuildContext.mounted).thenReturn(true);
          AuthenticationManager.auth = mockFirebaseAuth;  // Ensure the singleton instance uses the mock

          final errorCode = await AuthenticationManager.createUserWithEmailAndPassword(
              'test@example.com', 'password', 'username', 2000, mockBuildContext);
          expect(errorCode, isNull);
        });

    testWidgets('signIn should show error snackbar on failure', (WidgetTester tester) async {
      when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: 'test@example.com', password: 'password'))
          .thenThrow(FirebaseAuthException(code: 'wrong-password'));
      AuthenticationManager.auth = mockFirebaseAuth;  // Ensure the singleton instance uses the mock

      // Build the widget tree including MaterialApp and ScaffoldMessenger
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    await AuthenticationManager.signIn(
                        'test@example.com', 'password', context);
                  },
                  child: const Text('Sign In'),
                );
              },
            ),
          ),
        ),
      );

      // Trigger the sign-in process
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(); // Wait for the widget tree to rebuild

      // Verify that the snackbar is shown
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}