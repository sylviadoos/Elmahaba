import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/latest_items_entity.dart';

class LatestItemsModel<T> extends LatestItemsEntity<T> {
  const LatestItemsModel({super.items, super.total, super.unread});

  /// One part of the dashboard, each of its `items` read by [item] (null
  /// leaves one out): { "items": [ … ], "total": 7, "unread": 0 }
  factory LatestItemsModel.fromJson(
    Map<String, dynamic> json,
    T? Function(Map<String, dynamic> json) item,
  ) {
    final items = [for (final each in jsonObjects(json['items'])) ?item(each)];
    return LatestItemsModel(
      items: items,
      total: json['total'] as int? ?? items.length,
      unread: json['unread'] as int? ?? 0,
    );
  }
}
