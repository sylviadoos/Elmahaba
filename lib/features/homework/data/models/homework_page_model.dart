import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/homework/data/models/homework_model.dart';
import 'package:al_mahhaba_school/features/homework/data/models/homework_subject_model.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_page_entity.dart';

/// The body of `GET v1/parent/children/{id}/homework`.
class HomeworkPageModel extends HomeworkPageEntity {
  const HomeworkPageModel({
    required super.items,
    required super.page,
    required super.lastPage,
    required super.total,
    required super.unread,
    super.subjects,
  });

  /// { "data": [ …homework… ], "meta": { "page": 1, "per_page": 20,
  ///   "total": 2, "last_page": 1, "unread": 1,
  ///   "subjects": [ { "id": 3, "name": "Math" } ] } }
  factory HomeworkPageModel.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>? ?? const {};
    final page = meta['page'] as int? ?? 1;

    return HomeworkPageModel(
      items: [
        for (final item in jsonObjects(json['data']))
          HomeworkModel.fromJson(item),
      ],
      page: page,
      lastPage: meta['last_page'] as int? ?? page,
      total: meta['total'] as int? ?? 0,
      unread: meta['unread'] as int? ?? 0,
      subjects: [
        for (final subject in jsonObjects(meta['subjects']))
          HomeworkSubjectModel.fromJson(subject),
      ],
    );
  }
}
