import 'quiz_result.dart';

class StudyProgress {
  final Set<int> completedTermIds;
  final Set<int> reviewTermIds;
  final List<QuizResult> quizHistory;
  final int streak;
  final DateTime? lastStudyDate;

  const StudyProgress({
    this.completedTermIds = const {},
    this.reviewTermIds = const {},
    this.quizHistory = const [],
    this.streak = 0,
    this.lastStudyDate,
  });

  int get totalCompleted => completedTermIds.length;

  double get averageQuizAccuracy {
    if (quizHistory.isEmpty) return 0.0;
    final total = quizHistory.fold<double>(
      0.0,
      (sum, r) => sum + r.accuracy,
    );
    return total / quizHistory.length;
  }

  int get totalQuizScore {
    return quizHistory.fold<int>(0, (sum, r) => sum + r.correctCount);
  }

  int get totalQuizCount => quizHistory.length;

  StudyProgress copyWith({
    Set<int>? completedTermIds,
    Set<int>? reviewTermIds,
    List<QuizResult>? quizHistory,
    int? streak,
    DateTime? lastStudyDate,
  }) {
    return StudyProgress(
      completedTermIds: completedTermIds ?? this.completedTermIds,
      reviewTermIds: reviewTermIds ?? this.reviewTermIds,
      quizHistory: quizHistory ?? this.quizHistory,
      streak: streak ?? this.streak,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
    );
  }
}
