import 'package:befriend/models/authentication/date_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateManager', () {
    test('isOldEnough returns true if age is exactly on the birthday', () {
      DateTime today = DateTime.now();
      DateTime birthday = today.subtract(const Duration(days: 24*365 + 6));

      expect(DateManager.isOldEnough(birthday: birthday, age: 24), isTrue);
    });

    test('isOldEnough returns true if age is more than the specified age', () {
      DateTime today = DateTime.now();
      DateTime birthday = today.subtract(const Duration(days: 34*365));

      expect(DateManager.isOldEnough(birthday: birthday, age: 30), isTrue);
    });

    test('isOldEnough returns false if age is less than the specified age', () {
      DateTime today = DateTime.now();
      DateTime birthday = today.subtract(const Duration(days: 14*365));

      expect(DateManager.isOldEnough(birthday: birthday, age: 15), isFalse);
    });

    test('isOldEnough returns true if today is after the birthday in the same month and year', () {
      DateTime today = DateTime.now();
      DateTime birthday = today.subtract(const Duration(days: 24*365 + 6 + 1));

      expect(DateManager.isOldEnough(birthday: birthday, age: 24), isTrue);
    });

    test('isOldEnough returns false if today is before the birthday in the same month and year', () {
      DateTime today = DateTime.now();
      DateTime birthday = today.subtract(const Duration(days: 24*365 + 6 - 1));

      expect(DateManager.isOldEnough(birthday: birthday, age: 24), isFalse);
    });
  });
}
