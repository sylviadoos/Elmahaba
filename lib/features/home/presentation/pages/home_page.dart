import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/widgets/page_refresher.dart';
import 'package:al_mahhaba_school/core/widgets/state_message.dart';
import 'package:al_mahhaba_school/features/auth/presentation/widgets/retry_or_log_in_button.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_unread_bloc.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_unread_intent.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/children/presentation/extensions/children_context.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_state.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_view_model.dart';
import 'package:al_mahhaba_school/features/children/presentation/widgets/no_children_state.dart';
import 'package:al_mahhaba_school/features/home/domain/extensions/dashboard_chat_counts.dart';
import 'package:al_mahhaba_school/features/home/presentation/bloc/home_bloc.dart';
import 'package:al_mahhaba_school/features/home/presentation/bloc/home_intent.dart';
import 'package:al_mahhaba_school/features/home/presentation/bloc/home_state.dart';
import 'package:al_mahhaba_school/features/home/presentation/widgets/home_dashboard_skeleton.dart';
import 'package:al_mahhaba_school/features/attendance/presentation/extensions/holiday_labels.dart';
import 'package:al_mahhaba_school/features/home/presentation/widgets/home_header.dart';
import 'package:al_mahhaba_school/features/home/presentation/widgets/home_stats.dart';
import 'package:al_mahhaba_school/features/home/presentation/widgets/latest_updates.dart';
import 'package:al_mahhaba_school/features/home/presentation/widgets/today_banner.dart';
import 'package:al_mahhaba_school/features/shell/presentation/widgets/main_nav_bar.dart';

/// Parent home, all from the selected child's dashboard: today's
/// attendance, the latest result, absences, fees and messages, then their
/// newest announcements, homework and results. Kept up to date while the
/// app runs (see [PageRefresher]); pulling down asks again too.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HomeBloc>(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  @override
  void initState() {
    super.initState();
    _showSelectedChild();
  }

  /// The selected child's dashboard; nothing to show without children.
  void _showSelectedChild() {
    final child = context.read<ChildrenViewModel>().state.selectedChild;
    if (child == null) return;
    context.read<HomeBloc>().add(ShowChildIntent(child.studentId));
  }

  void _refresh() => context.read<HomeBloc>().add(const RefreshHomeIntent());

  /// Spins until the school answered (or Home closed).
  Future<void> _pullToRefresh() async {
    final bloc = context.read<HomeBloc>()..add(const RefreshHomeIntent());
    await bloc.stream.firstWhere(
      (state) =>
          !state.isRefreshing && state.dashboard.state != StateType.loading,
      orElse: () => bloc.state,
    );
  }

  @override
  Widget build(BuildContext context) {
    final childrenState = context.select(
      (ChildrenViewModel viewModel) => viewModel.state.children,
    );
    final children = childrenState.data ?? const <ChildEntity>[];

    return MultiBlocListener(
      listeners: [
        BlocListener<ChildrenViewModel, ChildrenState>(
          // The children arrived or changed (a child linked, the list
          // refreshed), or another one was picked, here or on another page.
          listenWhen: (previous, current) =>
              previous.children.data != current.children.data ||
              current.showsOtherChildThan(previous),
          listener: (context, state) => _showSelectedChild(),
        ),
        BlocListener<HomeBloc, HomeState>(
          // A dashboard came: the badge on Chat says what its School chat
          // card says, without asking again. Home learns of messages the
          // badge doesn't — with message notifications off no push comes,
          // and Home also asks when shown again or pulled down.
          listenWhen: (previous, current) =>
              current.dashboard.data != null &&
              current.dashboard.data != previous.dashboard.data,
          listener: (context, state) {
            final selected = context
                .read<ChildrenViewModel>()
                .state
                .selectedChild
                ?.studentId;
            final dashboard = state.dashboard.data;
            // Only the selected child's: the badge counts theirs.
            if (dashboard == null || state.childId != selected) return;
            context.read<ChatUnreadBloc>().add(
              SetChatUnreadIntent(dashboard.unreadChat.total),
            );
          },
        ),
      ],
      child: PageRefresher(
        path: AppRoutes.home,
        onRefresh: _refresh,
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HomeHeader(
                  children: children,
                  selectedChild: context.watchSelectedChildIndex(),
                  onChildSelected: (index) =>
                      context.selectChild(children[index].studentId),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _pullToRefresh,
                    child: SingleChildScrollView(
                      // Pulls down even when it all fits.
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        20.w,
                        4.h,
                        20.w,
                        MainNavBar.contentPadding(context),
                      ),
                      child: children.isEmpty
                          ? NoChildrenState(
                              children: childrenState,
                              loading: const HomeDashboardSkeleton(),
                            )
                          : const _Dashboard(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Dashboard extends StatelessWidget {
  const _Dashboard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (previous, current) =>
          previous.dashboard != current.dashboard ||
          previous.childId != current.childId ||
          previous.calendar != current.calendar,
      builder: (context, state) => state.dashboard.when(
        initial: () => const HomeDashboardSkeleton(),
        loading: () => const HomeDashboardSkeleton(),
        error: (exception) => StateMessage(
          icon: AppIcons.navResults,
          title: exception.localizedMessage(context),
          action: RetryOrLogInButton(
            exception: exception,
            onRetry: () =>
                context.read<HomeBloc>().add(const RefreshHomeIntent()),
          ),
        ),
        success: (dashboard) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 14.h,
          children: [
            TodayBanner(
              status: dashboard.attendance.todayStatus,
              holidayName: state.calendar
                  ?.holidayOn(DateTime.now())
                  ?.localName(context),
              isWeekend: state.calendar?.isWeekendOn(DateTime.now()) ?? false,
            ),
            HomeStats(dashboard: dashboard),
            LatestUpdates(dashboard: dashboard, childId: state.childId),
          ],
        ),
      ),
    );
  }
}
