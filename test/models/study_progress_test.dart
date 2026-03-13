import 'package:flutter_test/flutter_test.dart';
import 'package:startup_bite/models/study_progress.dart';
import 'package:startup_bite/models/quiz_result.dart';

void main() {
  group('StudyProgress', () {
    test('default values', () {
      const progress = StudyProgress();
      expect(progress.totalCompleted, 0);
      expect(progress.streak, 0);
      expect(progress.dailyGoal, 5);
      expect(progress.todayLearnedCount, 0);
      expect(progress.isDailyGoalReached, isFalse);
    });

    test('isDailyGoalReached', () {
      const progress = StudyProgress(dailyGoal: 3, todayLearnedCount: 3);
      expect(progress.isDailyGoalReached, isTrue);
    });

    test('dailyGoalProgress clamps to 1.0', () {
      const progress = StudyProgress(dailyGoal: 3, todayLearnedCount: 5);
      expect(progress.dailyGoalProgress, 1.0);
    });

    test('getConfidence returns 0 for unknown terms', () {
      const progress = StudyProgress();
      expect(progress.getConfidence(999), 0);
    });

    test('getConfidence returns stored value', () {
      const progress = StudyProgress(termConfidence: {1: 2, 5: 3});
      expect(progress.getConfidence(1), 2);
      expect(progress.getConfidence(5), 3);
    });

    test('averageQuizAccuracy', () {
      final progress = StudyProgress(
        quizHistory: [
          QuizResult(date: DateTime(2026, 1, 1), correctCount: 8, totalCount: 10),
          QuizResult(date: DateTime(2026, 1, 2), correctCount: 6, totalCount: 10),
        ],
      );
      expect(progress.averageQuizAccuracy, closeTo(0.7, 0.001));
    });

    test('averageQuizAccuracy is 0 with no history', () {
      const progress = StudyProgress();
      expect(progress.averageQuizAccuracy, 0.0);
    });

    test('copyWith preserves unmodified fields', () {
      const original = StudyProgress(
        streak: 5,
        dailyGoal: 10,
        todayLearnedCount: 3,
      );
      final modified = original.copyWith(streak: 6);
      expect(modified.streak, 6);
      expect(modified.dailyGoal, 10);
      expect(modified.todayLearnedCount, 3);
    });

    test('totalQuizScore sums correct counts', () {
      final progress = StudyProgress(
        quizHistory: [
          QuizResult(date: DateTime(2026, 1, 1), correctCount: 8, totalCount: 10),
          QuizResult(date: DateTime(2026, 1, 2), correctCount: 6, totalCount: 10),
        ],
      );
      expect(progress.totalQuizScore, 14);
    });

    group('SRS intervals', () {
      test('srsInterval returns correct durations', () {
        expect(StudyProgress.srsInterval(0), Duration.zero);
        expect(StudyProgress.srsInterval(1), const Duration(days: 1));
        expect(StudyProgress.srsInterval(2), const Duration(days: 3));
        expect(StudyProgress.srsInterval(3), const Duration(days: 7));
      });

      test('isDueForReview returns true when no date set', () {
        const progress = StudyProgress();
        expect(progress.isDueForReview(1), isTrue);
      });

      test('isDueForReview returns false for future date', () {
        final futureDate = DateTime.now().add(const Duration(days: 5));
        final progress = StudyProgress(nextReviewDates: {1: futureDate});
        expect(progress.isDueForReview(1), isFalse);
      });

      test('isDueForReview returns true for past date', () {
        final pastDate = DateTime.now().subtract(const Duration(days: 1));
        final progress = StudyProgress(nextReviewDates: {1: pastDate});
        expect(progress.isDueForReview(1), isTrue);
      });
    });
  });
}
