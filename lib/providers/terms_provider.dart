import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/term.dart';
import '../utils/app_date_utils.dart';

final termsProvider = FutureProvider<List<Term>>((ref) async {
  final jsonString = await rootBundle.loadString('assets/data/terms.json');
  final jsonData = json.decode(jsonString) as Map<String, dynamic>;
  final termsList = jsonData['terms'] as List;
  return termsList.map((e) => Term.fromJson(e as Map<String, dynamic>)).toList();
});

final todayTermProvider = Provider<AsyncValue<Term>>((ref) {
  final termsAsync = ref.watch(termsProvider);
  return termsAsync.when(
    data: (terms) {
      final index = AppDateUtils.getTodayTermIndex(
        ref.read(firstLaunchDateProvider),
      );
      return AsyncValue.data(terms[index]);
    },
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
  );
});

final firstLaunchDateProvider = Provider<DateTime>((ref) {
  // Will be overridden in main.dart
  return DateTime.now();
});

final termsByWeekProvider = Provider<AsyncValue<Map<int, List<Term>>>>((ref) {
  final termsAsync = ref.watch(termsProvider);
  return termsAsync.when(
    data: (terms) {
      final grouped = <int, List<Term>>{};
      for (final term in terms) {
        grouped.putIfAbsent(term.week, () => []).add(term);
      }
      return AsyncValue.data(grouped);
    },
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
  );
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchedTermsProvider = Provider<AsyncValue<List<Term>>>((ref) {
  final termsAsync = ref.watch(termsProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  return termsAsync.when(
    data: (terms) {
      if (query.isEmpty) return AsyncValue.data(terms);
      final filtered = terms.where((t) {
        return t.termKo.toLowerCase().contains(query) ||
            t.termEn.toLowerCase().contains(query) ||
            t.definitionShort.toLowerCase().contains(query);
      }).toList();
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
  );
});
