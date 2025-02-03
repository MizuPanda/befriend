class DailyStreak {
  static double friendMultiplier(final int streak) {
    if (streak == 1) {
      return 1.1;
    } else if (streak > 1 && streak <= 4) {
      return 1.2;
    } else if (streak > 4 && streak <= 9) {
      return 1.5;
    } else if (streak > 9) {
      return 2;
    }

    return 1;
  }

  // Last step multiplier + Additional multiplier / (upper bound - lower bound) * (streak - lowerBound)
  static double globalMultiplier(final int streak) {
    if (streak > 0 && streak <= 2) {
      return 1 + 0.05 / (2 - 0) * streak; // Range 1-2 | max at 1.05
    } else if (streak > 2 && streak <= 6) {
      return 1.05 + 0.05 / (6 - 2) * (streak - 2); // Range 3-6 | max at 1.1
    } else if (streak > 6 && streak <= 14) {
      return 1.1 + 0.15 / (14 - 6) * (streak - 6); // Range 7-14 | max at 1.25
    } else if (streak > 14) {
      return 1.5 + (streak - 15) * 0.005; // Range 15+ | no max
    }

    return 1;
  }
}
