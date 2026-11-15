import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_ineligible_reason.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_status.dart';

/// An excuse's `status`: "submitted", "info_required", "accepted" or
/// "rejected".
ExcuseStatus excuseStatusFromJson(Object? value) => switch (value) {
  'submitted' => ExcuseStatus.submitted,
  'info_required' => ExcuseStatus.infoRequired,
  'accepted' => ExcuseStatus.accepted,
  'rejected' => ExcuseStatus.rejected,
  _ => ExcuseStatus.unknown,
};

/// An absence's `ineligible_reason`; null for none.
ExcuseIneligibleReason? excuseIneligibleReasonFromJson(Object? value) =>
    switch (value) {
      null => null,
      'window_closed' => ExcuseIneligibleReason.windowClosed,
      'excuse_already_active' => ExcuseIneligibleReason.alreadyActive,
      'not_absent' => ExcuseIneligibleReason.notAbsent,
      'window_not_configured' => ExcuseIneligibleReason.windowNotConfigured,
      'read_only_child' => ExcuseIneligibleReason.readOnlyChild,
      _ => ExcuseIneligibleReason.unknown,
    };

/// "2026-11-04", or a time ("2026-11-04T10:15:00+00:00") in the phone's
/// zone; null when missing.
DateTime? excuseDateFromJson(Object? value) => switch (value) {
  final String text => DateTime.tryParse(text)?.toLocal(),
  _ => null,
};
