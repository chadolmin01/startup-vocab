import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/term.dart';
import '../providers/terms_provider.dart';
import '../providers/progress_provider.dart';
import '../utils/constants.dart';
import '../widgets/glass_container.dart';
import '../widgets/progress_bar.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  int _currentIndex = 0;
  bool _showAnswer = false;
  int _knowCount = 0;
  int _dontKnowCount = 0;
  List<Term> _reviewTerms = [];
  bool _finished = false;

  @override
  Widget build(BuildContext context) {
    final termsAsync = ref.watch(termsProvider);
    final progress = ref.watch(progressProvider);

    return Scaffold(
      body: SafeArea(
        child: termsAsync.when(
          data: (allTerms) {
            if (_reviewTerms.isEmpty && !_finished) {
              final completed = allTerms
                  .where((t) => progress.completedTermIds.contains(t.id))
                  .toList();
              completed.sort((a, b) {
                final confA = progress.getConfidence(a.id);
                final confB = progress.getConfidence(b.id);
                return confA.compareTo(confB);
              });
              _reviewTerms = completed;
            }

            if (_reviewTerms.isEmpty) {
              return _buildEmpty();
            }

            if (_finished) {
              return _buildResult();
            }

            return _buildReviewCard();
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text('ERROR: $e',
                style: AppTextStyles.label.copyWith(color: AppColors.error)),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.all(Spacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('REVIEW', style: AppTextStyles.labelColored(AppColors.accent)),
          const SizedBox(height: Spacing.xs),
          const Text('빠른 복습', style: AppTextStyles.h2),
          const SizedBox(height: Spacing.lg),
          Expanded(
            child: FrameContainer(
              label: 'STATUS // EMPTY',
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.menu_book, size: 32, color: AppColors.textMuted),
                    const SizedBox(height: Spacing.lg),
                    Text(
                      '복습할 용어가 없습니다',
                      style: AppTextStyles.bodySecondary,
                    ),
                    const SizedBox(height: Spacing.sm),
                    Text(
                      '먼저 용어를 학습해주세요',
                      style: AppTextStyles.small,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard() {
    final term = _reviewTerms[_currentIndex];
    final progress = ref.read(progressProvider);
    final confidence = progress.getConfidence(term.id);

    return Padding(
      padding: const EdgeInsets.all(Spacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('REVIEW', style: AppTextStyles.labelColored(AppColors.accent)),
                  const SizedBox(height: Spacing.xs),
                  const Text('빠른 복습', style: AppTextStyles.h2),
                ],
              ),
              Text(
                '${_currentIndex + 1} / ${_reviewTerms.length}',
                style: AppTextStyles.labelBright,
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          // Progress + confidence
          Row(
            children: [
              Expanded(
                child: ProgressBar(
                  percent: (_currentIndex + 1) / _reviewTerms.length,
                  progressColor: AppColors.accent,
                ),
              ),
              const SizedBox(width: Spacing.md),
              _confidenceDot(0, confidence),
              const SizedBox(width: 3),
              _confidenceDot(1, confidence),
              const SizedBox(width: 3),
              _confidenceDot(2, confidence),
              const SizedBox(width: 3),
              _confidenceDot(3, confidence),
              const SizedBox(width: Spacing.sm),
              Text(_confidenceLabel(confidence), style: AppTextStyles.label),
            ],
          ),
          const SizedBox(height: Spacing.lg),
          // Card
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showAnswer = true),
              child: FrameContainer(
                label: '${term.category} / WEEK ${term.week}',
                child: Center(
                  child: _showAnswer
                      ? SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(term.termKo, style: AppTextStyles.h1, textAlign: TextAlign.center),
                              const SizedBox(height: Spacing.sm),
                              Text(term.termEn, style: AppTextStyles.mono, textAlign: TextAlign.center),
                              const SizedBox(height: Spacing.xl),
                              Text(
                                term.definitionShort,
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.6,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(term.termKo, style: AppTextStyles.h1, textAlign: TextAlign.center),
                            const SizedBox(height: Spacing.md),
                            Text(term.termEn, style: AppTextStyles.mono, textAlign: TextAlign.center),
                            const SizedBox(height: Spacing.xxl),
                            Text(
                              'TAP TO REVEAL',
                              style: AppTextStyles.label.copyWith(color: AppColors.textMuted),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: Spacing.lg),
          // Actions
          if (_showAnswer)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _answer(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    child: const Text('모르겠어요'),
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _answer(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('알고 있어요'),
                  ),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => setState(() => _showAnswer = true),
                child: const Text('정답 보기'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _confidenceDot(int level, int current) {
    // level 0-3, current 0-3. current=3 → all 4 dots lit
    final active = current > level || (current == 3 && level == 3);
    final colors = [AppColors.error, AppColors.warning, AppColors.accent, AppColors.success];
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? colors[level] : AppColors.cardBorder,
      ),
    );
  }

  String _confidenceLabel(int confidence) {
    switch (confidence) {
      case 0: return 'NEW';
      case 1: return 'LEARNING';
      case 2: return 'FAMILIAR';
      case 3: return 'MASTERED';
      default: return '';
    }
  }

  void _answer(bool know) {
    final term = _reviewTerms[_currentIndex];
    if (know) {
      _knowCount++;
      ref.read(progressProvider.notifier).reviewKnow(term.id);
    } else {
      _dontKnowCount++;
      ref.read(progressProvider.notifier).reviewDontKnow(term.id);
    }

    if (_currentIndex + 1 >= _reviewTerms.length) {
      setState(() => _finished = true);
    } else {
      setState(() {
        _currentIndex++;
        _showAnswer = false;
      });
    }
  }

  Widget _buildResult() {
    final total = _knowCount + _dontKnowCount;

    return Padding(
      padding: const EdgeInsets.all(Spacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('REVIEW', style: AppTextStyles.labelColored(AppColors.accent)),
          const SizedBox(height: Spacing.xs),
          const Text('복습 완료', style: AppTextStyles.h2),
          const SizedBox(height: Spacing.lg),
          Expanded(
            child: FrameContainer(
              label: 'RESULT // COMPLETE',
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.psychology, size: 36, color: AppColors.accent),
                    const SizedBox(height: Spacing.xl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _resultStat('$_knowCount', 'KNOW', AppColors.success),
                        Container(width: 1, height: 40, color: AppColors.cardBorder),
                        _resultStat('$_dontKnowCount', "DON'T KNOW", AppColors.error),
                        Container(width: 1, height: 40, color: AppColors.cardBorder),
                        _resultStat('$total', 'TOTAL', AppColors.textSecondary),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: Spacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentIndex = 0;
                  _showAnswer = false;
                  _knowCount = 0;
                  _dontKnowCount = 0;
                  _reviewTerms = [];
                  _finished = false;
                });
              },
              child: const Text('다시 복습'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.stat.copyWith(color: color)),
        const SizedBox(height: Spacing.xs),
        Text(label, style: AppTextStyles.label),
      ],
    );
  }
}
