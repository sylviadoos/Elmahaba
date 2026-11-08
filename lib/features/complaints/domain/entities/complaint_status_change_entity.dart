import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_status.dart';

/// A complaint moving to [status], e.g. from submitted to under review.
class ComplaintStatusChangeEntity extends Equatable {
  const ComplaintStatusChangeEntity({required this.status, this.at});

  final ComplaintStatus status;
  final DateTime? at;

  @override
  List<Object?> get props => [status, at];
}
