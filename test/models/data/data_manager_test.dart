import 'package:befriend/models/authentication/authentication.dart';
import 'package:befriend/models/data/data_manager.dart';
import 'package:befriend/models/data/data_query.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'data_manager_test.mocks.dart';



@GenerateNiceMocks([
  MockSpec<DocumentSnapshot>(),
  MockSpec<AuthenticationManager>(),
  MockSpec<DataQuery>(),
])

void main() {
  final mockDocumentSnapshot = MockDocumentSnapshot();

  setUp(() {
    Constants.usersCollection = FakeFirebaseFirestore().collection('users');
  });

  group('DataManager', () {
    test('getNumber should return correct number', () {
      const String testNumber = 'testNumber';
      const num value = 42;
      when(mockDocumentSnapshot.data()).thenReturn({testNumber: value});
      when(mockDocumentSnapshot.get(testNumber)).thenReturn(value);

      final result = DataManager.getNumber(mockDocumentSnapshot, testNumber);
      expect(result, value);
    });

    test('getMap should return correct map', () {
      const String testMap = 'testMap';
      const value = {'key': 'value'};
      when(mockDocumentSnapshot.data()).thenReturn({testMap: value});
      when(mockDocumentSnapshot.get(testMap)).thenReturn(value);

      final result = DataManager.getMap(mockDocumentSnapshot, testMap);
      expect(result, value);
    });

    test('getDateTimeMap should return correct DateTime map', () {
      final timestamp = Timestamp.now();
      final value = {'user1': timestamp};
      when(mockDocumentSnapshot.data()).thenReturn({Constants.lastSeenUsersMapDoc: value});
      when(mockDocumentSnapshot.get(Constants.lastSeenUsersMapDoc)).thenReturn(value);

      final result = DataManager.getDateTimeMap(mockDocumentSnapshot, Constants.lastSeenUsersMapDoc);
      expect(result['user1'], timestamp.toDate());
    });

    test('getBoolean should return correct boolean', () {
      const String key = 'testBool';
      const bool value = true;

      when(mockDocumentSnapshot.data()).thenReturn({key: value});
      when(mockDocumentSnapshot.get(key)).thenReturn(value);

      final result = DataManager.getBoolean(mockDocumentSnapshot, 'testBool');
      expect(result, true);
    });

    test('getString should return correct string', () {
      const String key = 'testString';
      const String value = 'testValue';

      when(mockDocumentSnapshot.data()).thenReturn({key: value});
      when(mockDocumentSnapshot.get(key)).thenReturn(value);

      final result = DataManager.getString(mockDocumentSnapshot, key);
      expect(result, value);
    });

    test('getList should return correct list', () {
      const String key = 'testList';
      const List<String> value = ['item1', 'item2'];

      when(mockDocumentSnapshot.data()).thenReturn({key: value});
      when(mockDocumentSnapshot.get(key)).thenReturn(value);

      final result = DataManager.getList(mockDocumentSnapshot, key);
      expect(result, value);
    });

    test('getDateTime should return correct DateTime', () {
      const String key = 'testDateTime';
      final timestamp = Timestamp.now();

      when(mockDocumentSnapshot.data()).thenReturn({key:timestamp});
      when(mockDocumentSnapshot.get(key)).thenReturn(timestamp);

      final result = DataManager.getDateTime(mockDocumentSnapshot, key);
      expect(result, timestamp.toDate());
    });

    test('getDateTime should return epoch on error', () {
      when(mockDocumentSnapshot.get('testDateTime')).thenThrow(Exception('Error'));

      final result = DataManager.getDateTime(mockDocumentSnapshot, 'testDateTime');
      expect(result, DateTime.utc(0));
    });
  });
}
