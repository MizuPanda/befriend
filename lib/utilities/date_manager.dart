class DateManager {
  static bool isBeforeYesterday(final DateTime dateTime) {
    // Get the current date and time
    final now = DateTime.now();

    // Calculate yesterday's date (without time)
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    // Check if the given dateTime is before yesterday's date
    return dateTime.isBefore(yesterday);
  }

  static bool isOldEnough(
      {required final DateTime birthday, required final int age}) {
    final DateTime today = DateTime.now();
    final int yearDiff = today.year - birthday.year;
    final int monthDiff = today.month - birthday.month;
    final int dayDiff = today.day - birthday.day;

    return yearDiff > age ||
        (yearDiff == age &&
            (monthDiff > 0 || (monthDiff == 0 && dayDiff >= 0)));
  }
}
