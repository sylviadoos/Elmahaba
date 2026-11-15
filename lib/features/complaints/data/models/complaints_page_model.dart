import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/complaints/data/models/complaint_model.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaints_page_entity.dart';

/// The body of `GET v1/parent/complaints?page=1&per_page=20`.
class ComplaintsPageModel extends ComplaintsPageEntity {
  const ComplaintsPageModel({
    required super.complaints,
    required super.page,
    required super.lastPage,
    required super.total,
  });

  /// { "data": [ …complaint… ],
  ///   "meta": { "page": 1, "per_page": 20, "total": 1, "last_page": 1 } }
  factory ComplaintsPageModel.fromJson(Map<String, dynamic> json) {
    final complaints = [
      for (final complaint in jsonObjects(json['data']))
        ComplaintModel.fromJson(complaint),
    ];
    final meta = json['meta'] as Map<String, dynamic>? ?? const {};
    final page = meta['page'] as int? ?? 1;

    return ComplaintsPageModel(
      complaints: complaints,
      page: page,
      lastPage: meta['last_page'] as int? ?? page,
      total: meta['total'] as int? ?? complaints.length,
    );
  }
}
