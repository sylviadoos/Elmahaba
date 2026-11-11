import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/features/results/domain/entities/monthly_certificate_entity.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_sheet_entity.dart';

/// A child's monthly results: the sheets published, and the certificate
/// they make.
class MonthlyResultsEntity extends Equatable {
  const MonthlyResultsEntity({this.sheets = const [], this.certificate});

  /// Newest first.
  final List<ResultSheetEntity> sheets;

  /// null when the school sends none.
  final MonthlyCertificateEntity? certificate;

  /// Whether there's a month to show.
  bool get hasMonths => certificate?.months.isNotEmpty ?? false;

  @override
  List<Object?> get props => [sheets, certificate];
}
