import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_unread_bloc.dart';
import 'package:al_mahhaba_school/features/chat/presentation/extensions/chat_unread_context.dart';
import 'package:al_mahhaba_school/features/shell/presentation/widgets/main_nav_bar.dart';

/// Home's branch, which back comes to from the other tabs.
const int _home = 0;

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
    // Signed in: the badge on Chat and the dot on Complaints. Both are
    // asked for again as notifications arrive (`BadgeRefresher`), and the
    // badge as another child is picked.
    context.loadChatUnread();
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
    // The tabs share one route, so one of these covers them all: back from
    // Results, Attendance or Fees shows Home, and back on Home leaves the
    // app, as always. The pages opened over them have their own
    // (`HomeOnBack`).
    return PopScope(
      canPop: widget.navigationShell.currentIndex == _home,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) widget.navigationShell.goBranch(_home);
      },
      child: Stack(
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
      ),
    );
  }
}
