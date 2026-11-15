import 'package:al_mahhaba_school/features/fees/domain/entities/installment_status.dart';

/// An installment's status as the API writes it ("PAID", "OVERDUE"…), for
/// the fees and Home's dashboard alike.
InstallmentStatus installmentStatusFromJson(Object? value) => switch (value) {
  'PAID' => InstallmentStatus.paid,
  'OVERDUE' => InstallmentStatus.overdue,
  'UPCOMING' => InstallmentStatus.upcoming,
  'UNDER_PROCESSING' => InstallmentStatus.processing,
  'UNDER_SETTLEMENT' => InstallmentStatus.underSettlement,
  _ => InstallmentStatus.unknown,
};
