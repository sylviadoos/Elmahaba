import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/core/notifications/notification_service.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/parent_view_model.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_unread_bloc.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_unread_intent.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/bloc/complaint_updates_bloc.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/bloc/complaint_updates_intent.dart';

/// Keeps the badge on Chat and the dot on Complaints right while the app
/// runs: each notification that arrives asks the school what's new, and so
/// does coming back to the app, for the ones that arrived while it was
/// away. Without this they would only be right at launch — a parent would
/// have to close the app and open it again to see a new message.
///
/// A push carries no counts, so what it says isn't read: it only says
/// something happened. It wraps the whole app (see `app.dart`), so the
/// badges follow whichever page the parent is on.
class BadgeRefresher extends StatefulWidget {
  const BadgeRefresher({super.key, required this.child});

  final Widget child;

  @override
  State<BadgeRefresher> createState() => _BadgeRefresherState();
}

class _BadgeRefresherState extends State<BadgeRefresher>
    with WidgetsBindingObserver {
  StreamSubscription<Map<String, dynamic>>? _notifications;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _notifications = getIt<NotificationService>().onReceived.listen(
      (_) => _refresh(),
    );
  }

  @override
  void dispose() {
    unawaited(_notifications?.cancel());
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Back from the home screen or another app: pushes may have arrived
  /// while it was away, and those don't reach [NotificationService].
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  void _refresh() {
    // Nothing to count for a visitor, and the API would answer 401.
    if (!mounted || context.read<ParentViewModel>().state.data == null) return;
    context.read<ChatUnreadBloc>().add(const LoadChatUnreadIntent());
    context.read<ComplaintUpdatesBloc>().add(
      const LoadComplaintUpdatesIntent(),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
