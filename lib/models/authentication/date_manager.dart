class DateManager {
  static bool isOldEnough({required DateTime birthday, required int age}) {
    DateTime today = DateTime.now();
    int yearDiff = today.year - birthday.year;
    int monthDiff = today.month - birthday.month;
    int dayDiff = today.day - birthday.day;

    return yearDiff > age ||
        (yearDiff == age &&
            (monthDiff > 0 || (monthDiff == 0 && dayDiff >= 0)));
  }
}
