import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/term.dart';
import '../models/quiz_result.dart';
import '../providers/terms_provider.dart';
import '../providers/progress_provider.dart';
import '../utils/constants.dart';

enum QuizType { definitionToTerm, termToDefinition }
enum QuizMode { normal, wrongOnly }

class QuizQuestion {
  final Term term;
  final QuizType type;
  final List<String> options;
  final int correctIndex;

  const QuizQuestion({
    required this.term,
    required this.type,
    required this.options,
    required this.correctIndex,
  });

  String get questionText {
    if (type == QuizType.definitionToTerm) {
      return '다음 설명에 해당하는 용어는?';
    }
    return '"${term.termKo}"의 올바른 설명은?';
  }

  String get questionBody {
    if (type == QuizType.definitionToTerm) {
      return term.definitionShort;
    }
    return '';
  }
}

class QuizState {
  final List<QuizQuestion> questions;
  final int currentIndex;
  final int correctCount;
  final int? selectedAnswer;
  final bool isFinished;
  final QuizMode mode;

  const QuizState({
    this.questions = const [],
    this.currentIndex = 0,
    this.correctCount = 0,
    this.selectedAnswer,
    this.isFinished = false,
    this.mode = QuizMode.normal,
  });

  QuizQuestion? get currentQuestion =>
      questions.isNotEmpty && currentIndex < questions.length
          ? questions[currentIndex]
          : null;

  int get totalQuestions => questions.length;

  double get progress =>
      totalQuestions > 0 ? (currentIndex) / totalQuestions : 0.0;

  QuizState copyWith({
    List<QuizQuestion>? questions,
    int? currentIndex,
    int? correctCount,
    int? selectedAnswer,
    bool? isFinished,
    QuizMode? mode,
  }) {
    return QuizState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      correctCount: correctCount ?? this.correctCount,
      selectedAnswer: selectedAnswer,
      isFinished: isFinished ?? this.isFinished,
      mode: mode ?? this.mode,
    );
  }
}

final quizProvider =
    StateNotifierProvider<QuizNotifier, QuizState>((ref) {
  return QuizNotifier(ref);
});

class QuizNotifier extends StateNotifier<QuizState> {
  final Ref _ref;
  final _random = Random();

  QuizNotifier(this._ref) : super(const QuizState());

  Future<void> generateQuiz({QuizMode mode = QuizMode.normal}) async {
    final termsAsync = _ref.read(termsProvider);
    final progress = _ref.read(progressProvider);

    final allTerms = termsAsync.valueOrNull;
    if (allTerms == null) return;

    List<Term> pool;
    if (mode == QuizMode.wrongOnly) {
      // Only wrong terms
      pool = allTerms
          .where((t) => progress.wrongTermIds.contains(t.id))
          .toList();
    } else {
      // SRS-weighted selection: lower confidence = higher chance
      final completedIds = progress.completedTermIds;
      if (completedIds.length < AppConstants.quizMinTerms) return;

      final studiedTerms =
          allTerms.where((t) => completedIds.contains(t.id)).toList();

      // Weight by inverse confidence: conf 0 → weight 4, conf 3 → weight 1
      final weighted = <Term>[];
      for (final term in studiedTerms) {
        final conf = progress.getConfidence(term.id);
        final weight = 4 - conf; // 0→4, 1→3, 2→2, 3→1
        for (int i = 0; i < weight; i++) {
          weighted.add(term);
        }
      }
      weighted.shuffle(_random);

      // Deduplicate while preserving priority order
      final seen = <int>{};
      pool = [];
      for (final term in weighted) {
        if (seen.add(term.id)) {
          pool.add(term);
        }
      }
    }

    if (pool.isEmpty) return;

    final questionCount = min(AppConstants.quizQuestionCount, pool.length);
    final selectedTerms = pool.take(questionCount).toList();

    final questions = <QuizQuestion>[];
    for (final term in selectedTerms) {
      final conf = progress.getConfidence(term.id);
      // Mastered terms (conf >= 3) → reverse quiz (definition → term)
      // Lower confidence → normal quiz (term → definition)
      final QuizType type;
      if (conf >= 3) {
        type = QuizType.definitionToTerm;
      } else if (conf >= 2) {
        // 50/50 chance of reverse
        type = _random.nextBool()
            ? QuizType.definitionToTerm
            : QuizType.termToDefinition;
      } else {
        type = QuizType.termToDefinition;
      }
      questions.add(_createQuestion(term, type));
    }

    state = QuizState(questions: questions, mode: mode);
  }

  QuizQuestion _createQuestion(Term term, QuizType type) {
    if (type == QuizType.definitionToTerm) {
      final correctAnswer = term.termKo;
      final termsAsync = _ref.read(termsProvider);
      final allTerms = termsAsync.valueOrNull ?? [];
      final otherTerms = allTerms
          .where((t) => t.id != term.id)
          .map((t) => t.termKo)
          .toList();
      otherTerms.shuffle(_random);
      final wrongTermNames = otherTerms.take(3).toList();

      final options = [correctAnswer, ...wrongTermNames]..shuffle(_random);
      final correctIndex = options.indexOf(correctAnswer);
      return QuizQuestion(
        term: term,
        type: type,
        options: options,
        correctIndex: correctIndex,
      );
    } else {
      final correctAnswer = term.definitionShort;
      final wrongAnswers = List<String>.from(term.quizWrongAnswers);
      final options = [correctAnswer, ...wrongAnswers]..shuffle(_random);
      final correctIndex = options.indexOf(correctAnswer);
      return QuizQuestion(
        term: term,
        type: type,
        options: options,
        correctIndex: correctIndex,
      );
    }
  }

  void submitAnswer(int selectedIndex) {
    if (state.selectedAnswer != null) return;
    final question = state.currentQuestion;
    if (question == null) return;

    final isCorrect = selectedIndex == question.correctIndex;
    state = state.copyWith(
      selectedAnswer: selectedIndex,
      correctCount:
          isCorrect ? state.correctCount + 1 : state.correctCount,
    );

    // Update SRS confidence
    _ref
        .read(progressProvider.notifier)
        .updateConfidence(question.term.id, isCorrect);
  }

  void nextQuestion() {
    if (state.currentIndex + 1 >= state.totalQuestions) {
      state = state.copyWith(isFinished: true);
      _saveResult();
    } else {
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
      );
    }
  }

  void _saveResult() {
    final result = QuizResult(
      date: DateTime.now(),
      correctCount: state.correctCount,
      totalCount: state.totalQuestions,
    );
    _ref.read(progressProvider.notifier).addQuizResult(result);
  }

  void reset() {
    state = const QuizState();
  }
}
