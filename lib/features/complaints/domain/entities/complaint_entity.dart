import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_status.dart';

/// One of the parent's complaints.
class ComplaintEntity extends Equatable {
  const ComplaintEntity({
    required this.id,
    required this.reference,
    required this.categoryEn,
    required this.categoryAr,
    required this.childName,
    required this.childNameAr,
    required this.status,
    required this.isOpen,
    required this.canReply,
    this.submittedAt,
    this.lastUpdate,
  });

  final int id;

  /// The school's reference number, e.g. "CMP-2026-00012".
  final String reference;

  /// The category's name in English and in Arabic.
  final String categoryEn;
  final String categoryAr;

  /// The child it's about; both empty for a general complaint.
  final String childName;
  final String childNameAr;

  final ComplaintStatus status;

  /// Until the school closes it.
  final bool isOpen;

  /// The school asked the parent something and takes a reply.
  final bool canReply;
  final DateTime? submittedAt;

  /// When the school or the parent last changed it.
  final DateTime? lastUpdate;

  @override
  List<Object?> get props => [
    id,
    reference,
    categoryEn,
    categoryAr,
    childName,
    childNameAr,
    status,
    isOpen,
    canReply,
    submittedAt,
    lastUpdate,
  ];
}
