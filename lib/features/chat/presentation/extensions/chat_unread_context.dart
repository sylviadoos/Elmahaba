import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_unread_bloc.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_unread_intent.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_view_model.dart';

extension ChatUnreadContext on BuildContext {
  /// The badge on Chat asks again, for the child every page shows. Nothing
  /// without one yet: it's asked once the children are here.
  void loadChatUnread() {
    final child = read<ChildrenViewModel>().state.selectedChild;
    if (child == null) return;
    read<ChatUnreadBloc>().add(LoadChatUnreadIntent(child.studentId));
  }
}
