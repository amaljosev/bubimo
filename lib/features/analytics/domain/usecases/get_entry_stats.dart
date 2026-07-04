// lib/features/analytics/domain/usecases/get_entry_stats.dart

import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../diary_entry/domain/usecases/get_all_diary_entries.dart';

/// Simple aggregate stats derived from all diary entries.
class EntryStats extends Equatable {
  final int totalEntries;
  final int totalWords;

  const EntryStats({required this.totalEntries, required this.totalWords});

  @override
  List<Object?> get props => [totalEntries, totalWords];
}

/// Computes total entry count and total word count across every diary
/// entry. `wordCount` is precomputed and stored per-entry on save (see
/// diary_entry's rich editor milestone), so this is just a fast
/// summation — no re-parsing of content.
///
/// Usage: `await getEntryStats()`.
class GetEntryStats {
  final GetAllDiaryEntries getAllDiaryEntries;

  const GetEntryStats(this.getAllDiaryEntries);

  Future<Either<Failure, EntryStats>> call() async {
    final result = await getAllDiaryEntries();

    return result.map((entries) {
      final totalWords = entries.fold<int>(
        0,
        (sum, entry) => sum + entry.wordCount,
      );
      return EntryStats(totalEntries: entries.length, totalWords: totalWords);
    });
  }
}