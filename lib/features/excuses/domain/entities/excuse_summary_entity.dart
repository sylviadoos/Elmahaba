import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_status.dart';

/// The excuse sent for a day, in short.
class ExcuseSummaryEntity extends Equatable {
  const ExcuseSummaryEntity({
    required this.id,
    required this.status,
    this.submittedAt,
  });

  final int id;
  final ExcuseStatus status;
  final DateTime? submittedAt;

  @override
  List<Object?> get props => [id, status, submittedAt];
}
