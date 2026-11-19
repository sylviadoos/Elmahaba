import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/core/notifications/app_icon_badge.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_unread_bloc.dart';

/// Puts the badge on Chat on the app's icon too, so the number outside the
/// app is what's new inside it, and goes once it's all read (or the parent
/// logs out).
///
/// The number on the icon also comes with the school's pushes (iOS), and
/// those may say something else: it's put back to the app's own count at
/// launch and every time the app comes back to the front, even when that
/// count didn't change. It wraps the whole app (see `app.dart`), under
/// [ChatUnreadBloc].
class AppIconBadgeSync extends StatefulWidget {
  const AppIconBadgeSync({super.key, required this.child});

  final Widget child;

  @override
  State<AppIconBadgeSync> createState() => _AppIconBadgeSyncState();
}

class _AppIconBadgeSyncState extends State<AppIconBadgeSync>
    with WidgetsBindingObserver {
  final AppIconBadge _badge = getIt<AppIconBadge>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _show(context.read<ChatUnreadBloc>().state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _show(context.read<ChatUnreadBloc>().state);
    }
  }

  void _show(int count) => unawaited(_badge.show(count));

  @override
  Widget build(BuildContext context) => BlocListener<ChatUnreadBloc, int>(
    listener: (_, count) => _show(count),
    child: widget.child,
  );
}
