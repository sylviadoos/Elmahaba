import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/chat/data/models/chat_item_model.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_page_entity.dart';

/// The body of `GET v1/parent/chat?limit=30`.
class ChatPageModel extends ChatPageEntity {
  const ChatPageModel({
    required super.items,
    required super.hasMore,
    super.nextBefore,
    required super.unread,
    required super.isOpen,
    required super.canSend,
  });

  /// { "data": [ …item… ], "meta": { "has_more": true,
  ///   "next_before": "WyIy…", "unread": 2, "chat_open": true,
  ///   "can_send": true } }
  factory ChatPageModel.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>? ?? const {};
    final nextBefore = meta['next_before'] as String?;

    return ChatPageModel(
      items: [
        for (final item in jsonObjects(json['data']))
          ChatItemModel.fromJson(item),
      ],
      // Without a cursor there's no way to ask for more.
      hasMore: (meta['has_more'] as bool? ?? false) && nextBefore != null,
      nextBefore: nextBefore,
      unread: meta['unread'] as int? ?? 0,
      // Open unless it says it's closed; `can_send` still decides sending.
      isOpen: meta['chat_open'] as bool? ?? true,
      canSend: meta['can_send'] as bool? ?? false,
    );
  }
}
