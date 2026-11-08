import 'package:al_mahhaba_school/core/network/api_keys.dart';
import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/latest_items_entity.dart';

class LatestItemsModel<T> extends LatestItemsEntity<T> {
  const LatestItemsModel({super.items, super.total, super.unread});

  /// The whole response, each of `data` read by [item]:
  /// { "status": "success", "data": [ … ],
  ///   "meta": { "limit": 3, "total": 7, "unread": 0 } }
  factory LatestItemsModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) item,
  ) {
    final items = [
      for (final each in jsonObjects(json[ApiKeys.data])) item(each),
    ];
    final meta = switch (json['meta']) {
      final Map<String, dynamic> meta => meta,
      _ => const <String, dynamic>{},
    };
    return LatestItemsModel(
      items: items,
      total: meta['total'] as int? ?? items.length,
      unread: meta['unread'] as int? ?? 0,
    );
  }
}
