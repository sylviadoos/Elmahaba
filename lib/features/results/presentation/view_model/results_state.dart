import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_details_entity.dart';

/// The selected child's results on Results, and the one shown.
class ResultsState extends Equatable {
  const ResultsState({
    this.childId,
    this.results = const BaseState.initial(),
    this.selectedId,
  });

  /// Whose they are, by `studentId`; null before the children load.
  final int? childId;

  /// Newest first; empty before any is published.
  final BaseState<List<ResultDetailsEntity>> results;

  /// The one picked in the filter; null shows the newest.
  final int? selectedId;

  /// The one shown: the one picked, else the newest; null with none.
  ResultDetailsEntity? get selected {
    final all = results.data ?? const [];
    return all.where((result) => result.id == selectedId).firstOrNull ??
        all.firstOrNull;
  }

  /// What goes on the certificate with [selected], when it's a month's:
  /// every month of its school year, oldest first. Empty for a term's.
  List<ResultDetailsEntity> get certificateMonths {
    final shown = selected;
    if (shown == null || !shown.isMonthly) return const [];
    return [
      for (final result in (results.data ?? const []).reversed)
        if (result.isMonthly && result.academicYear == shown.academicYear)
          result,
    ];
  }

  ResultsState copyWith({
    BaseState<List<ResultDetailsEntity>>? results,
    int? selectedId,
  }) => ResultsState(
    childId: childId,
    results: results ?? this.results,
    selectedId: selectedId ?? this.selectedId,
  );

  @override
  List<Object?> get props => [childId, results, selectedId];
}
