import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/dashed_border.dart';
import 'package:al_mahhaba_school/core/widgets/load_more_indicator.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_item_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_page_entity.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_intent.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_state.dart';
import 'package:al_mahhaba_school/features/chat/presentation/extensions/chat_labels.dart';
import 'package:al_mahhaba_school/features/chat/presentation/extensions/chat_link_navigation.dart';
import 'package:al_mahhaba_school/features/chat/presentation/widgets/chat_day_label.dart';
import 'package:al_mahhaba_school/features/chat/presentation/widgets/chat_older_failed.dart';
import 'package:al_mahhaba_school/features/chat/presentation/widgets/chat_parent_bubble.dart';
import 'package:al_mahhaba_school/features/chat/presentation/widgets/chat_school_item.dart';

/// A row of the list, and how to build it once it comes on screen.
typedef _Row = ({Key key, WidgetBuilder build});

/// The chat's items, newest at the bottom, where it opens: older ones
/// (while there are more, loading as the top comes near), then each day's
/// label and items. The school's items are set apart by a dashed line; the
/// parent's sit under what they follow.
///
/// A row is built only as it comes on screen, and keeps its place by its
/// item (its key), so a message sent or older ones loaded leave the others
/// as they are. An unread item marks itself seen as it comes.
class ChatItemsList extends StatelessWidget {
  const ChatItemsList({
    super.key,
    required this.state,
    required this.page,
    required this.scroll,
    this.topPadding = 0,
  });

  final ChatState state;

  /// [state]'s items.
  final ChatPageEntity page;
  final ScrollController scroll;

  /// Room above the oldest, so it clears what lies over the list's top.
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    final rows = _rows(context);
    final last = rows.length - 1;
    // Reversed: it opens at the newest, and older ones load above without
    // moving it.
    final indexOf = {for (final (i, row) in rows.indexed) row.key: last - i};

    return ListView.builder(
      controller: scroll,
      reverse: true,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(16.w, 8.h + topPadding, 16.w, 16.h),
      itemCount: rows.length,
      findChildIndexCallback: (key) => indexOf[key],
      itemBuilder: (context, index) {
        final row = rows[last - index];
        // Each row built under its own context: what it watches (e.g. the
        // excuse opening) rebuilds that row, not the whole list.
        return KeyedSubtree(
          key: row.key,
          child: Builder(builder: row.build),
        );
      },
    );
  }

  /// From the top. Only what each row needs to be found; it's built later.
  List<_Row> _rows(BuildContext context) {
    final bloc = context.read<ChatBloc>();
    void loadOlder() => bloc.add(const LoadOlderChatIntent());

    final byKey = {for (final item in page.items) item.key: item};
    final rows = <_Row>[
      if (page.hasMore)
        if (state.chat.state == StateType.error)
          (
            key: const ValueKey('older:failed'),
            build: (_) => ChatOlderFailed(onRetry: loadOlder),
          )
        else
          (
            // A new cursor asks for the page after it.
            key: ValueKey('older:${page.nextBefore}'),
            build: (_) => LoadMoreIndicator(onShown: loadOlder),
          ),
    ];

    DateTime? day;
    ChatItemEntity? previous;
    for (final item in page.items) {
      final sentAt = item.sentAt;
      if (sentAt != null && (day == null || !sentAt.isSameDay(day))) {
        day = sentAt;
        previous = null;
        rows.add((
          key: ValueKey('day:${sentAt.year}-${sentAt.month}-${sentAt.day}'),
          build: (context) => Padding(
            padding: EdgeInsets.only(top: 18.h),
            child: ChatDayLabel(sentAt.chatDayLabel(context)),
          ),
        ));
      }
      if (item.fromParent) {
        rows.add((
          key: ValueKey('item:${item.key}'),
          build: (context) => _Seen(
            onSeen: _seen(bloc, item),
            child: Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: ChatParentBubble(
                item: item,
                answered: _answered(context, item, byKey),
                // Everything: whom each message is about shows.
                showChildren: state.studentId == null,
              ),
            ),
          ),
        ));
      } else {
        if (previous != null) {
          rows.add((
            key: ValueKey('line:${item.key}'),
            build: (_) => Padding(
              padding: EdgeInsets.only(top: 18.h),
              child: const DashedLine(),
            ),
          ));
        }
        rows.add((
          key: ValueKey('item:${item.key}'),
          build: (context) => _Seen(
            onSeen: _seen(bloc, item),
            child: Padding(
              padding: EdgeInsets.only(top: 18.h),
              child: ChatSchoolItem(
                item: item,
                // Homework of the child it's about (or the one shown).
                onOpenLink: (link) => context.openChatLink(
                  link,
                  studentId:
                      item.children.firstOrNull?.studentId ?? state.studentId,
                ),
                onReply: state.canReplyTo(item)
                    ? () => bloc.add(StartReplyIntent(item))
                    : null,
              ),
            ),
          ),
        ));
      }
      previous = item;
    }
    return rows;
  }

  /// Marks [item] read once it's on screen; null when it's read already.
  static VoidCallback? _seen(ChatBloc bloc, ChatItemEntity item) =>
      item.isRead ? null : () => bloc.add(ItemSeenIntent(item.key));

  /// What [item] answers, in a line; null when it answers nothing.
  static String? _answered(
    BuildContext context,
    ChatItemEntity item,
    Map<String, ChatItemEntity> byKey,
  ) {
    final replyTo = item.replyTo;
    if (replyTo == null) return null;
    if (replyTo.isDeleted) return context.l10n.deletedMessage;
    // Not loaded (older than what's shown).
    return byKey[replyTo.key]?.snippet(context) ?? context.l10n.earlierMessage;
  }
}

/// Calls [onSeen] once, as its row is first built: it's on screen, or
/// about to be.
class _Seen extends StatefulWidget {
  const _Seen({required this.onSeen, required this.child});

  final VoidCallback? onSeen;
  final Widget child;

  @override
  State<_Seen> createState() => _SeenState();
}

class _SeenState extends State<_Seen> {
  @override
  void initState() {
    super.initState();
    widget.onSeen?.call();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
