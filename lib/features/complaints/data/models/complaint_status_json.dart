import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_status.dart';

/// The API's status, e.g. "under_review"; null for one this app doesn't
/// know yet.
ComplaintStatus? complaintStatusFromJson(Object? value) => switch (value) {
  'submitted' => ComplaintStatus.submitted,
  'under_review' => ComplaintStatus.underReview,
  'awaiting_parent' => ComplaintStatus.awaitingParentResponse,
  'resolved' => ComplaintStatus.resolved,
  'rejected' => ComplaintStatus.rejected,
  _ => null,
};
