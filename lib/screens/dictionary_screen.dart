import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/terms_provider.dart';
import '../providers/progress_provider.dart';
import '../models/study_progress.dart';
import '../models/term.dart';
import '../utils/constants.dart';
import '../widgets/category_badge.dart';
import '../widgets/progress_bar.dart';
import 'term_detail_screen.dart';

class DictionaryScreen extends ConsumerWidget {
  const DictionaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(searchQueryProvider);
    final progress = ref.watch(progressProvider);
    final termsByWeekAsync = ref.watch(termsByWeekProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search bar
                  TextField(
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: '용어 검색...',
                      hintStyle:
                          const TextStyle(color: AppColors.textSecondary),
                      prefixIcon: const Icon(Icons.search,
                          color: AppColors.textSecondary),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear,
                                  color: AppColors.textSecondary),
                              onPressed: () => ref
                                  .read(searchQueryProvider.notifier)
                                  .state = '',
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      ref.read(searchQueryProvider.notifier).state = value;
                    },
                  ),
                  const SizedBox(height: 12),
                  // Progress
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${progress.totalCompleted} / ${AppConstants.totalTerms} 학습 완료',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${(progress.totalCompleted / AppConstants.totalTerms * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ProgressBar(
                    percent:
                        progress.totalCompleted / AppConstants.totalTerms,
                  ),
                ],
              ),
            ),
            Expanded(
              child: searchQuery.isNotEmpty
                  ? _buildSearchResults(ref, progress)
                  : _buildWeeklyList(termsByWeekAsync, progress, context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(WidgetRef ref, StudyProgress progress) {
    final searchResults = ref.watch(searchedTermsProvider);
    return searchResults.when(
      data: (terms) {
        if (terms.isEmpty) {
          return const Center(
            child: Text('검색 결과가 없습니다',
                style: TextStyle(color: AppColors.textSecondary)),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: terms.length,
          itemBuilder: (context, index) {
            final term = terms[index];
            final isCompleted = progress.completedTermIds.contains(term.id);
            return _buildTermTile(context, term, isCompleted);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('오류: $e')),
    );
  }

  Widget _buildWeeklyList(
    AsyncValue<Map<int, List<Term>>> termsByWeek,
    StudyProgress progress,
    BuildContext context,
  ) {
    return termsByWeek.when(
      data: (grouped) {
        final weeks = grouped.keys.toList()..sort();
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: weeks.length,
          itemBuilder: (context, weekIndex) {
            final week = weeks[weekIndex];
            final terms = grouped[week]!;
            final category = terms.first.category;
            final categoryColor = AppColors.getCategoryColor(category);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: categoryColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Week $week',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      CategoryBadge(
                          category: category, fontSize: 11),
                    ],
                  ),
                ),
                ...terms.map((term) {
                  final isCompleted =
                      progress.completedTermIds.contains(term.id);
                  return _buildTermTile(context, term, isCompleted);
                }),
                const SizedBox(height: 8),
              ],
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('오류: $e')),
    );
  }

  Widget _buildTermTile(BuildContext context, Term term, bool isCompleted) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          isCompleted ? Icons.check_circle : Icons.circle_outlined,
          color: isCompleted ? AppColors.success : AppColors.textSecondary,
          size: 22,
        ),
        title: Text(
          term.termKo,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          term.termEn,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(Icons.chevron_right,
            color: AppColors.textSecondary, size: 20),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TermDetailScreen(term: term),
            ),
          );
        },
      ),
    );
  }
}
