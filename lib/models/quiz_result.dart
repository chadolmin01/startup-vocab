class QuizResult {
  final DateTime date;
  final int correctCount;
  final int totalCount;

  const QuizResult({
    required this.date,
    required this.correctCount,
    required this.totalCount,
  });

  double get accuracy =>
      totalCount > 0 ? correctCount / totalCount : 0.0;

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'correctCount': correctCount,
        'totalCount': totalCount,
      };

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      date: DateTime.parse(json['date'] as String),
      correctCount: json['correctCount'] as int,
      totalCount: json['totalCount'] as int,
    );
  }
}
