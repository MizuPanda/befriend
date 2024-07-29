import 'package:befriend/models/authentication/authentication.dart';
import 'package:befriend/models/data/data_manager.dart';
import 'package:befriend/models/data/data_query.dart';
import 'package:befriend/models/objects/friendship.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:befriend/utilities/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../firebase_mock.dart';
import 'data_query_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseAuth>(),
  MockSpec<DataManager>(),
  MockSpec<DocumentSnapshot>(),
  MockSpec<QueryDocumentSnapshot<Map<String, dynamic>>>(),
  MockSpec<FirebaseStorage>(),
  MockSpec<Reference>(),
  MockSpec<User>(),
])
void main() {
  // TestWidgetsFlutterBinding.ensureInitialized(); Gets called in setupFirebaseAuthMocks()
  setupFirebaseAuthMocks();

  final mockFirebaseAuth = MockFirebaseAuth();
  final mockUser = MockUser();
  final mockDocumentSnapshot = MockDocumentSnapshot();
  final mockQueryDocumentSnapshot = MockQueryDocumentSnapshot();
  final mockFirebaseStorage = MockFirebaseStorage();
  final mockReference = MockReference();
  final mockDataManager = MockDataManager();
  final fakeFirestore = FakeFirebaseFirestore();

  setUp(() {
    Constants.usersCollection = fakeFirestore.collection('users');
    Constants.friendshipsCollection = fakeFirestore.collection('friendships');
    Models.dataManager = mockDataManager;

    when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('user1');
    AuthenticationManager.auth = mockFirebaseAuth;
  });

  group('DataQuery', () {
    test('updateDocument should update the document with the given data', () async {
      final userDoc = fakeFirestore.collection('users').doc('test-id');
      await userDoc.set({'fieldID': 'oldData'});

      await DataQuery.updateDocument('fieldID', 'newData', userId: 'test-id');

      final updatedDoc = await userDoc.get();
      expect(updatedDoc['fieldID'], 'newData');
    });

    test('getFriendship should return a Friendship object', () async {
      Constants.friendshipsCollection = fakeFirestore.collection('friendships');
      final friendshipDoc = fakeFirestore.collection('friendships').doc('friendship-id');
      await friendshipDoc.set({'someField': 'someValue'});

      when(mockDocumentSnapshot.get(Constants.avatarDoc)).thenReturn('http://example.com/avatar.png');
      when(mockDataManager.getAvatar(any)).thenAnswer((_) async => const NetworkImage('http://example.com/avatar.png'));
      when(mockDataManager.getData(id: anyNamed('id'))).thenAnswer((_) async => mockDocumentSnapshot);
      when(mockQueryDocumentSnapshot.get(any)).thenReturn('someValue');

      final result = await DataQuery.getFriendship('user1', 'user2');
      expect(result, isA<Friendship>());
    });

    test('getFriendship should throw exception on error', () async {
      when(mockDataManager.getData(id: anyNamed('id'))).thenThrow(Exception('Error'));

      expect(() => DataQuery.getFriendship('user1', 'user2'), throwsException);
    });

    test('getNetworkImage should return NetworkImage if url is valid', () async {
      DataQuery.storage = mockFirebaseStorage;
      when(mockReference.getDownloadURL()).thenAnswer((_) async => 'http://example.com/avatar.png');
      when(mockFirebaseStorage.refFromURL(any)).thenReturn(mockReference);

      final result = await Models.dataQuery.getNetworkImage('http://example.com/avatar.png');
      expect(result, isA<NetworkImage>());
    });

    test('getNetworkImage should return default image on error', () async {
      when(mockReference.getDownloadURL()).thenThrow(Exception('Error'));

      final result = await Models.dataQuery.getNetworkImage('invalid_url');
      expect(result, isA<AssetImage>());
    });
  });
}
