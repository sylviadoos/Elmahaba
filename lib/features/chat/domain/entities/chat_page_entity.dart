import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/features/chat/domain/entities/chat_item_entity.dart';

/// Part of the chat, from the newest back: [items] (oldest first), and
/// where the older ones start.
class ChatPageEntity extends Equatable {
  const ChatPageEntity({
    required this.items,
    required this.hasMore,
    this.nextBefore,
    required this.unread,
    required this.isOpen,
    required this.canSend,
  });

  final List<ChatItemEntity> items;

  /// There are older items, from [nextBefore].
  final bool hasMore;
  final String? nextBefore;

  /// What the parent hasn't read yet, in the whole chat.
  final int unread;

  /// False while the school has closed the chat: it can still be read, but
  /// takes no messages ([canSend] is false too).
  final bool isOpen;

  /// False while none of the parent's children is enrolled, or the chat is
  /// closed ([isOpen]): the school takes no messages.
  final bool canSend;

  /// [older]'s items, then these; older ones after it come from [older]'s
  /// cursor. Any already here are skipped.
  ChatPageEntity after(ChatPageEntity older) {
    final loaded = {for (final item in items) item.key};
    return ChatPageEntity(
      items: [
        for (final item in older.items)
          if (!loaded.contains(item.key)) item,
        ...items,
      ],
      hasMore: older.hasMore,
      nextBefore: older.nextBefore,
      unread: unread,
      isOpen: isOpen,
      canSend: canSend,
    );
  }

  /// These, then [item] (just sent), unless it's here already.
  ChatPageEntity followedBy(ChatItemEntity item) => ChatPageEntity(
    items: [
      for (final shown in items)
        if (shown.key != item.key) shown,
      item,
    ],
    hasMore: hasMore,
    nextBefore: nextBefore,
    unread: unread,
    isOpen: isOpen,
    canSend: canSend,
  );

  /// These, with the items under [keys] read or not ([isRead]), and
  /// [unread] left in the whole chat when the school said.
  ChatPageEntity withRead(
    Set<String> keys, {
    required bool isRead,
    int? unread,
  }) => ChatPageEntity(
    items: [
      for (final item in items)
        keys.contains(item.key) && item.isRead != isRead
            ? item.withRead(isRead)
            : item,
    ],
    hasMore: hasMore,
    nextBefore: nextBefore,
    unread: unread ?? this.unread,
    isOpen: isOpen,
    canSend: canSend,
  );

  /// These, with the chat closed: the school closed it after they loaded.
  ChatPageEntity closed() => ChatPageEntity(
    items: items,
    hasMore: hasMore,
    nextBefore: nextBefore,
    unread: unread,
    isOpen: false,
    canSend: false,
  );

  @override
  List<Object?> get props => [
    items,
    hasMore,
    nextBefore,
    unread,
    isOpen,
    canSend,
  ];
}
