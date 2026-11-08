import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/features/auth/domain/use_cases/logout_use_case.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/parent_event.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/parent_view_model.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_unread_intent.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_unread_bloc.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_event.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_view_model.dart';

extension LogOut on BuildContext {
  /// Forgets the saved session, parent, children and chat badge — so the
  /// next launch (or parent) doesn't see them — and opens Log in. For "Log
  /// out", and when the server says the session ended.
  Future<void> logOut() async {
    await getIt<LogoutUseCase>()();
    if (!mounted) return;
    read<ParentViewModel>().doAction(const ClearParentEvent());
    read<ChildrenViewModel>().doAction(const ClearChildrenEvent());
    read<ChatUnreadBloc>().add(const ClearChatUnreadIntent());
    go(AppRoutes.login);
  }
}
