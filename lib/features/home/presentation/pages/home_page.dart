import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_button.dart';
import 'package:al_mahhaba_school/core/widgets/state_message.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/children/presentation/extensions/children_context.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_state.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_view_model.dart';
import 'package:al_mahhaba_school/features/children/presentation/widgets/no_children_state.dart';
import 'package:al_mahhaba_school/features/home/presentation/bloc/latest_updates_bloc.dart';
import 'package:al_mahhaba_school/features/home/presentation/bloc/latest_updates_intent.dart';
import 'package:al_mahhaba_school/features/home/presentation/view_model/home_event.dart';
import 'package:al_mahhaba_school/features/home/presentation/view_model/home_state.dart';
import 'package:al_mahhaba_school/features/home/presentation/view_model/home_view_model.dart';
import 'package:al_mahhaba_school/features/home/presentation/widgets/home_dashboard_skeleton.dart';
import 'package:al_mahhaba_school/features/home/presentation/widgets/home_header.dart';
import 'package:al_mahhaba_school/features/home/presentation/widgets/home_stats.dart';
import 'package:al_mahhaba_school/features/home/presentation/widgets/latest_updates.dart';
import 'package:al_mahhaba_school/features/home/presentation/widgets/today_banner.dart';
import 'package:al_mahhaba_school/features/shell/presentation/widgets/main_nav_bar.dart';

/// Parent home: today's attendance, the latest result, attendance, fees and
/// messages for the selected child, then their newest announcements,
/// homework and results.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<HomeViewModel>()),
        BlocProvider(create: (_) => getIt<LatestUpdatesBloc>()),
      ],
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
    _loadDashboard();
  }

  /// The selected child's dashboard and latest updates; nothing to load
  /// without children.
  void _loadDashboard() {
    final child = context.read<ChildrenViewModel>().state.selectedChild;
    if (child == null) return;
    context.read<HomeViewModel>().doAction(LoadDashboardEvent(child.studentId));
    context.read<LatestUpdatesBloc>().add(
      ShowChildUpdatesIntent(child.studentId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final childrenState = context.select(
      (ChildrenViewModel viewModel) => viewModel.state.children,
    );
    final children = childrenState.data ?? const <ChildEntity>[];

    return BlocListener<ChildrenViewModel, ChildrenState>(
      // The children arrived or changed (a child linked, the list
      // refreshed), or another one was picked, here or on another page.
      listenWhen: (previous, current) =>
          previous.children.data != current.children.data ||
          current.showsOtherChildThan(previous),
      listener: (context, state) => _loadDashboard(),
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
                child: SingleChildScrollView(
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
                      : _dashboard(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dashboard(BuildContext context) {
    return BlocBuilder<HomeViewModel, HomeState>(
      builder: (context, state) => state.dashboard.when(
        initial: () => const HomeDashboardSkeleton(),
        loading: () => const HomeDashboardSkeleton(),
        error: (exception) => StateMessage(
          icon: AppIcons.navResults,
          title: exception.localizedMessage(context),
          action: AppButton(
            label: context.l10n.tryAgain,
            expand: false,
            onPressed: _loadDashboard,
          ),
        ),
        success: (dashboard) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 14.h,
          children: [
            TodayBanner(status: dashboard.attendance.todayStatus),
            HomeStats(dashboard: dashboard),
            const LatestUpdates(),
          ],
        ),
      ),
    );
  }
}
