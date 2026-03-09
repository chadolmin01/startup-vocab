import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../providers/quiz_provider.dart';
import '../providers/progress_provider.dart';
import '../models/study_progress.dart';
import '../utils/constants.dart';
import '../widgets/glass_container.dart';
import '../widgets/quiz_option_tile.dart';
import '../widgets/progress_bar.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  bool _started = false;

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(progressProvider);
    final quizState = ref.watch(quizProvider);
    final canTakeQuiz =
        progress.completedTermIds.length >= AppConstants.quizMinTerms;

    if (!canTakeQuiz) {
      return _buildNotEnoughTerms(progress.completedTermIds.length);
    }

    if (!_started) {
      return _buildStartScreen(progress);
    }

    if (quizState.isFinished) {
      return _buildResultScreen(quizState);
    }

    return _buildQuizQuestion(quizState);
  }

  Widget _buildNotEnoughTerms(int current) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: GlassContainer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.quiz, size: 48, color: AppColors.accent),
                  const SizedBox(height: 16),
                  const Text(
                    '퀴즈 모드',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '용어를 ${AppConstants.quizMinTerms}개 이상 학습하면\n퀴즈에 도전할 수 있어요!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '현재 $current / ${AppConstants.quizMinTerms}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStartScreen(StudyProgress progress) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: GlassContainer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.quiz, size: 48, color: AppColors.accent),
                  const SizedBox(height: 16),
                  const Text(
                    '퀴즈 모드',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '학습한 ${progress.completedTermIds.length}개 용어 중\n최대 ${AppConstants.quizQuestionCount}문제가 출제됩니다.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ref.read(quizProvider.notifier).generateQuiz();
                        setState(() => _started = true);
                      },
                      child: const Text('퀴즈 시작'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuizQuestion(QuizState quizState) {
    final question = quizState.currentQuestion;
    if (question == null) return const SizedBox();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${quizState.currentIndex + 1} / ${quizState.totalQuestions}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${quizState.correctCount}개 정답',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ProgressBar(
                percent: (quizState.currentIndex + 1) /
                    quizState.totalQuestions,
                progressColor: AppColors.accent,
              ),
              const SizedBox(height: 24),
              GlassContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question.questionText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (question.questionBody.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        question.questionBody,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: question.options.length,
                  itemBuilder: (context, index) {
                    return QuizOptionTile(
                      text: question.options[index],
                      index: index,
                      selectedAnswer: quizState.selectedAnswer,
                      correctIndex: question.correctIndex,
                      onTap: () {
                        ref
                            .read(quizProvider.notifier)
                            .submitAnswer(index);
                      },
                    );
                  },
                ),
              ),
              if (quizState.selectedAnswer != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(quizProvider.notifier).nextQuestion();
                    },
                    child: Text(
                      quizState.currentIndex + 1 >= quizState.totalQuestions
                          ? '결과 보기'
                          : '다음 문제',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultScreen(QuizState quizState) {
    final accuracy = quizState.totalQuestions > 0
        ? quizState.correctCount / quizState.totalQuestions
        : 0.0;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: GlassContainer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '퀴즈 완료!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CircularPercentIndicator(
                    radius: 70,
                    lineWidth: 10,
                    percent: accuracy,
                    center: Text(
                      '${(accuracy * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    progressColor:
                        accuracy >= 0.7 ? AppColors.success : AppColors.warning,
                    backgroundColor: AppColors.cardBorder,
                    circularStrokeCap: CircularStrokeCap.round,
                    animation: true,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${quizState.correctCount} / ${quizState.totalQuestions} 정답',
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ref.read(quizProvider.notifier).reset();
                        setState(() => _started = false);
                      },
                      child: const Text('다시 도전'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
