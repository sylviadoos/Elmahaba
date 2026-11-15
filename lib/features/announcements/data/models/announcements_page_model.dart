import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/announcements/domain/entities/announcements_page_entity.dart';
import 'package:al_mahhaba_school/features/home/data/models/announcement_model.dart';

/// The body of `GET v1/parent/children/{id}/announcements`.
class AnnouncementsPageModel extends AnnouncementsPageEntity {
  const AnnouncementsPageModel({
    required super.items,
    required super.page,
    required super.lastPage,
    required super.total,
    required super.unread,
  });

  /// { "data": [ …announcement… ], "meta": { "page": 1, "per_page": 10,
  ///   "total": 2, "last_page": 1, "unread": 1 } }
  factory AnnouncementsPageModel.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>? ?? const {};
    final page = meta['page'] as int? ?? 1;

    return AnnouncementsPageModel(
      items: [
        for (final item in jsonObjects(json['data']))
          AnnouncementModel.fromJson(item),
      ],
      page: page,
      lastPage: meta['last_page'] as int? ?? page,
      total: meta['total'] as int? ?? 0,
      unread: meta['unread'] as int? ?? 0,
    );
  }
}
