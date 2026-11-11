import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/certificate_month_entity.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/monthly_results_entity.dart';

/// The monthly results of the child shown, and the month picked.
class MonthlyResultsState extends Equatable {
  const MonthlyResultsState({
    this.childId,
    this.results = const BaseState.initial(),
    this.selectedKey,
  });

  /// The child shown, by `studentId`; null before the children load.
  final int? childId;
  final BaseState<MonthlyResultsEntity> results;

  /// The month shown, by its key ("m1"); the newest at first.
  final String? selectedKey;

  /// The month shown; null with none.
  CertificateMonthEntity? get selectedMonth {
    final months = results.data?.certificate?.months ?? const [];
    return months.where((month) => month.key == selectedKey).firstOrNull ??
        months.lastOrNull;
  }

  MonthlyResultsState copyWith({
    BaseState<MonthlyResultsEntity>? results,
    String? selectedKey,
  }) => MonthlyResultsState(
    childId: childId,
    results: results ?? this.results,
    selectedKey: selectedKey ?? this.selectedKey,
  );

  @override
  List<Object?> get props => [childId, results, selectedKey];
}
