import 'constants.dart';

class AppDateUtils {
  static int getTodayTermIndex(DateTime firstLaunchDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(
      firstLaunchDate.year,
      firstLaunchDate.month,
      firstLaunchDate.day,
    );
    final daysSinceStart = today.difference(start).inDays;
    return daysSinceStart % AppConstants.totalTerms;
  }

  static int getDayNumber(DateTime firstLaunchDate) {
    return getTodayTermIndex(firstLaunchDate) + 1;
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  static int calculateStreak(DateTime? lastStudyDate, int currentStreak) {
    if (lastStudyDate == null) return 0;
    if (isToday(lastStudyDate)) return currentStreak;
    if (isYesterday(lastStudyDate)) return currentStreak;
    return 0; // 2일 이상 미학습 → 리셋
  }

  /// Formatted date string for today: yyyy-MM-dd
  static String todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
