import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_unread_intent.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_unread_bloc.dart';
import 'package:al_mahhaba_school/features/shell/presentation/widgets/main_nav_bar.dart';

/// The parent app's tabs under one nav bar, which stays in place while
/// they switch. Each tab keeps its state (the child picked, the scroll…)
/// while another one is shown. Chat opens on top.
class ParentShellPage extends StatefulWidget {
  const ParentShellPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  /// The router's branches, in order.
  static const List<MainTab> tabs = [
    MainTab.home,
    MainTab.results,
    MainTab.attendance,
    MainTab.fees,
  ];

  @override
  State<ParentShellPage> createState() => _ParentShellPageState();
}

class _ParentShellPageState extends State<ParentShellPage> {
  @override
  void initState() {
    super.initState();
    // Signed in: the badge on Chat.
    context.read<ChatUnreadBloc>().add(const LoadChatUnreadIntent());
  }

  void _open(BuildContext context, MainTab tab) {
    if (tab == MainTab.chat) {
      // It has a back button.
      context.push(AppRoutes.chat);
      return;
    }
    widget.navigationShell.goBranch(ParentShellPage.tabs.indexOf(tab));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.navigationShell,
        Positioned(
          left: 16.w,
          right: 16.w,
          bottom: MainNavBar.bottomOffset(context),
          // The tabs' own Scaffolds are under it; its taps need one.
          child: Material(
            type: MaterialType.transparency,
            child: MainNavBar(
              current:
                  ParentShellPage.tabs[widget.navigationShell.currentIndex],
              chatUnread: context.watch<ChatUnreadBloc>().state,
              onSelected: (tab) => _open(context, tab),
            ),
          ),
        ),
      ],
    );
  }
}
