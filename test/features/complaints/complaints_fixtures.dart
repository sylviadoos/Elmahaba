import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_entity.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_status.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaints_page_entity.dart';

/// One of the parent's complaints, changed [lastUpdate] ago.
ComplaintEntity complaint({int id = 12, DateTime? lastUpdate}) =>
    ComplaintEntity(
      id: id,
      reference: 'CMP-2026-000$id',
      categoryEn: 'Transport',
      categoryAr: 'النقل',
      childName: 'Omar Ahmed',
      childNameAr: 'عمر أحمد',
      status: ComplaintStatus.underReview,
      isOpen: true,
      canReply: false,
      submittedAt: DateTime(2026, 11, 3, 9, 15),
      lastUpdate: lastUpdate,
    );

/// The first (and only) page holding [complaints].
ComplaintsPageEntity complaintsPage(List<ComplaintEntity> complaints) =>
    ComplaintsPageEntity(
      complaints: complaints,
      page: 1,
      lastPage: 1,
      total: complaints.length,
    );
