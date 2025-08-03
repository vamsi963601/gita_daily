import 'package:shared_preferences/shared_preferences.dart';

/// Manages the user's daily streak persistence and logic.
///
/// This class handles saving and retrieving the streak count and the date
/// of the last visit to ensure continuity between app sessions.
class StreakManager {
  // Define constant keys for storing data in SharedPreferences.
  // This prevents typos and makes the code easier to maintain.
  static const String _streakCountKey = 'streakCount';
  static const String _lastVisitDateKey = 'lastVisitDate';

  /// Updates the streak based on the current date and the last visit date.
  ///
  /// This method should be called once every time the app is opened.
  Future<void> updateStreak() async {
    final prefs = await SharedPreferences.getInstance();

    // Get today's date with the time component stripped out.
    // This is important to ensure we are only comparing dates, not times.
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Retrieve the last visit date string from storage.
    final lastVisitString = prefs.getString(_lastVisitDateKey);

    if (lastVisitString == null) {
      // This is the user's first visit.
      // Start their streak at 1.
      await prefs.setInt(_streakCountKey, 1);
    } else {
      // The user has visited before. Parse the stored date.
      final lastVisitDate = DateTime.parse(lastVisitString);

      // Calculate the difference in days between the last visit and today.
      final difference = today.difference(lastVisitDate).inDays;

      if (difference == 1) {
        // It's a consecutive day visit. Increment the streak.
        int currentStreak = prefs.getInt(_streakCountKey) ?? 0;
        await prefs.setInt(_streakCountKey, currentStreak + 1);
      } else if (difference > 1) {
        // The user missed one or more days. Reset the streak to 1.
        await prefs.setInt(_streakCountKey, 1);
      }
      // If `difference` is 0, the user has already visited today.
      // We do nothing to avoid incrementing the streak multiple times in one day.
    }

    // Always update the last visit date to today's date.
    await prefs.setString(_lastVisitDateKey, today.toIso8601String());
  }

  /// Retrieves the current streak count from storage.
  ///
  /// Returns 0 if no streak has been recorded yet.
  Future<int> getStreakCount() async {
    final prefs = await SharedPreferences.getInstance();
    // Use the null-aware operator '??' to default to 0 if the key doesn't exist.
    return prefs.getInt(_streakCountKey) ?? 0;
  }

  /// Resets the streak count to 0.
  ///
  /// This is useful for debugging or if you want to provide a user-facing
  /// option to reset their progress.
  Future<void> resetStreak() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_streakCountKey, 0);
    await prefs.remove(_lastVisitDateKey); // Also remove the last visit date
  }
}