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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search bar
                  TextField(
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: '용어 검색...',
                      hintStyle: const TextStyle(color: AppColors.textMuted),
                      prefixIcon: const Icon(Icons.search,
                          color: AppColors.textMuted, size: 18),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear,
                                  color: AppColors.textMuted, size: 16),
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
                        'PROGRESS',
                        style: AppTextStyles.label,
                      ),
                      Text(
                        '${progress.totalCompleted} / ${AppConstants.totalTerms}',
                        style: AppTextStyles.labelColored(AppColors.accent).copyWith(fontSize: 11),
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
            const Divider(height: 1),
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
          return Center(
            child: Text('NO RESULTS', style: AppTextStyles.label),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: terms.length,
          itemBuilder: (context, index) {
            final term = terms[index];
            final isCompleted = progress.completedTermIds.contains(term.id);
            return _buildTermTile(context, term, isCompleted);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('ERROR: $e')),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        width: 3,
                        height: 16,
                        color: categoryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'WEEK $week',
                        style: AppTextStyles.labelBright.copyWith(fontSize: 11),
                      ),
                      const SizedBox(width: 8),
                      CategoryBadge(category: category),
                    ],
                  ),
                ),
                ...terms.map((term) {
                  final isCompleted =
                      progress.completedTermIds.contains(term.id);
                  return _buildTermTile(context, term, isCompleted);
                }),
                if (weekIndex < weeks.length - 1)
                  const Divider(height: 24),
              ],
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('ERROR: $e')),
    );
  }

  Widget _buildTermTile(BuildContext context, Term term, bool isCompleted) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(4),
        color: AppColors.cardBackground,
      ),
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        leading: Icon(
          isCompleted ? Icons.check : Icons.circle_outlined,
          color: isCompleted ? AppColors.success : AppColors.textMuted,
          size: 16,
        ),
        title: Text(
          term.termKo,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          term.termEn,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ),
        trailing: const Icon(Icons.chevron_right,
            color: AppColors.textMuted, size: 16),
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
