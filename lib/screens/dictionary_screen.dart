import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/terms_provider.dart';
import '../providers/progress_provider.dart';
import '../models/study_progress.dart';
import '../models/term.dart';
import '../utils/constants.dart';
import '../widgets/category_badge.dart';
import '../widgets/progress_bar.dart';
import '../widgets/star_field.dart';
import 'term_detail_screen.dart';

class DictionaryScreen extends ConsumerStatefulWidget {
  const DictionaryScreen({super.key});

  @override
  ConsumerState<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends ConsumerState<DictionaryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(searchQueryProvider);
    final progress = ref.watch(progressProvider);
    final termsByWeekAsync = ref.watch(termsByWeekProvider);

    return Scaffold(
      body: StarField(
        starCount: 30,
        showShootingStars: false,
        child: SafeArea(
          child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(Spacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchController,
                    style: AppTextStyles.body,
                    decoration: InputDecoration(
                      hintText: '용어 검색...',
                      prefixIcon: const Icon(Icons.search,
                          color: AppColors.textMuted, size: 18),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear,
                                  color: AppColors.textMuted, size: 16),
                              onPressed: () {
                                _searchController.clear();
                                ref
                                    .read(searchQueryProvider.notifier)
                                    .state = '';
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      ref.read(searchQueryProvider.notifier).state = value;
                    },
                  ),
                  const SizedBox(height: Spacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('PROGRESS', style: AppTextStyles.label),
                      Text(
                        '${progress.totalCompleted} / ${AppConstants.totalTerms}',
                        style: AppTextStyles.labelColored(AppColors.accent),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.sm),
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
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.screenPadding,
            vertical: Spacing.md,
          ),
          itemCount: terms.length,
          itemBuilder: (context, index) {
            final term = terms[index];
            final isCompleted = progress.completedTermIds.contains(term.id);
            return _buildTermTile(context, term, isCompleted);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('ERROR: $e',
            style: AppTextStyles.label.copyWith(color: AppColors.error)),
      ),
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
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.screenPadding,
            vertical: Spacing.md,
          ),
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
                  padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                  child: Row(
                    children: [
                      Container(
                        width: 3,
                        height: 16,
                        decoration: BoxDecoration(
                          color: categoryColor,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      const SizedBox(width: Spacing.sm),
                      Text(
                        'WEEK $week',
                        style: AppTextStyles.labelBright,
                      ),
                      const SizedBox(width: Spacing.sm),
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
                  const Divider(height: Spacing.xl),
              ],
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('ERROR: $e',
            style: AppTextStyles.label.copyWith(color: AppColors.error)),
      ),
    );
  }

  Widget _buildTermTile(BuildContext context, Term term, bool isCompleted) {
    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        color: AppColors.cardBackground,
      ),
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Spacing.lg,
          vertical: Spacing.xs,
        ),
        leading: Icon(
          isCompleted ? Icons.check_circle : Icons.circle_outlined,
          color: isCompleted ? AppColors.success : AppColors.textMuted,
          size: 18,
        ),
        title: Text(term.termKo, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(term.termEn, style: AppTextStyles.mono),
        trailing: const Icon(Icons.chevron_right,
            color: AppColors.textMuted, size: 18),
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
