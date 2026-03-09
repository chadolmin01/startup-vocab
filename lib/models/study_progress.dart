import 'quiz_result.dart';

class StudyProgress {
  final Set<int> completedTermIds;
  final Set<int> reviewTermIds;
  final List<QuizResult> quizHistory;
  final int streak;
  final DateTime? lastStudyDate;

  // Daily goal
  final int dailyGoal;
  final int todayLearnedCount;
  final String todayDate; // yyyy-MM-dd

  // SRS confidence: 0=new, 1=wrong, 2=correct once, 3=mastered
  final Map<int, int> termConfidence;

  // Wrong answer tracking
  final Set<int> wrongTermIds;

  const StudyProgress({
    this.completedTermIds = const {},
    this.reviewTermIds = const {},
    this.quizHistory = const [],
    this.streak = 0,
    this.lastStudyDate,
    this.dailyGoal = 5,
    this.todayLearnedCount = 0,
    this.todayDate = '',
    this.termConfidence = const {},
    this.wrongTermIds = const {},
  });

  int get totalCompleted => completedTermIds.length;

  bool get isDailyGoalReached => todayLearnedCount >= dailyGoal;

  double get dailyGoalProgress =>
      dailyGoal > 0 ? (todayLearnedCount / dailyGoal).clamp(0.0, 1.0) : 0.0;

  int getConfidence(int termId) => termConfidence[termId] ?? 0;

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
    int? dailyGoal,
    int? todayLearnedCount,
    String? todayDate,
    Map<int, int>? termConfidence,
    Set<int>? wrongTermIds,
  }) {
    return StudyProgress(
      completedTermIds: completedTermIds ?? this.completedTermIds,
      reviewTermIds: reviewTermIds ?? this.reviewTermIds,
      quizHistory: quizHistory ?? this.quizHistory,
      streak: streak ?? this.streak,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      todayLearnedCount: todayLearnedCount ?? this.todayLearnedCount,
      todayDate: todayDate ?? this.todayDate,
      termConfidence: termConfidence ?? this.termConfidence,
      wrongTermIds: wrongTermIds ?? this.wrongTermIds,
    );
  }
}
